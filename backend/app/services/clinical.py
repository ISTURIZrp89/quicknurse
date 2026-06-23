"""
Servicios clínicos para QuickNurse - Capa de lógica de negocio.
Implementa operaciones CRUD y reglas de negocio para:
- Patient (perfil clínico completo)
- Medication + DrugInteraction (farmacología)
- Prescription (prescripciones con validaciones)
- Episode + ClinicalNote + ClinicalDocument (historia clínica)
- Timeline unificado
"""
from datetime import datetime, timezone, timedelta, date
from decimal import Decimal
from typing import Optional, List
from sqlalchemy import select, and_, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlalchemy.orm import Session as SyncSession

from app.models import (
    Patient, VitalSigns, VitalSource,
    User, UserRole,
    Medication, MedicationStatus, DrugInteraction,
    PregnancyCategory, LactationCategory,
    Prescription, PrescriptionStatus,
    Episode, EpisodeType, EpisodeStatus,
    ClinicalNote, ClinicalDocument,
    ChatConversation, TimerTurno, NotaTraspaso, PlanPAE, Turno, Credencial, DrugReference,
)


# =====================================================================
# PATIENT SERVICE
# =====================================================================

class PatientService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, data: dict, creator: User) -> Patient:
        # Verificar user existe y no tiene patient profile
        stmt = select(User).where(User.id == data.get("user_id"))
        result = await self.session.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError("Usuario no encontrado")

        stmt = select(Patient).where(Patient.user_id == user.id)
        result = await self.session.execute(stmt)
        if result.scalar_one_or_none():
            raise ValueError("Usuario ya tiene perfil de paciente")

        # Verificar clinician si se proporciona
        if data.get("clinician_id"):
            stmt = select(User).where(
                User.id == data["clinician_id"],
                User.rol == UserRole.CLINICIAN,
                User.activo == True
            )
            result = await self.session.execute(stmt)
            if not result.scalar_one_or_none():
                raise ValueError("Clínico no encontrado o inactivo")

        patient = Patient(**data)
        self.session.add(patient)
        await self.session.flush()
        return patient

    async def get_by_id(self, patient_id: int) -> Optional[Patient]:
        stmt = select(Patient).where(Patient.id == patient_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: int) -> Optional[Patient]:
        stmt = select(Patient).where(Patient.user_id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_patients(
        self,
        clinician_id: Optional[int] = None,
        active_only: bool = True,
        skip: int = 0,
        limit: int = 50
    ) -> List[Patient]:
        stmt = select(Patient)
        if active_only:
            stmt = stmt.where(Patient.is_active == True)
        if clinician_id:
            stmt = stmt.where(Patient.clinician_id == clinician_id)
        stmt = stmt.order_by(Patient.last_name, Patient.first_name).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def update(self, patient: Patient, data: dict) -> Patient:
        vital_fields = {"baseline_bp_systolic", "baseline_bp_diastolic", "baseline_heart_rate",
                        "baseline_temperature", "baseline_spo2", "baseline_weight", "baseline_height"}
        changed_vitals = vital_fields & set(data.keys())
        if changed_vitals:
            patient.vitals_updated_at = datetime.now(timezone.utc)

        for field, value in data.items():
            setattr(patient, field, value)
        await self.session.flush()
        return patient

    async def assign_clinician(self, patient_id: int, clinician_id: int) -> Patient:
        patient = await self.get_by_id(patient_id)
        if not patient:
            raise ValueError("Paciente no encontrado")

        stmt = select(User).where(
            User.id == clinician_id,
            User.rol == UserRole.CLINICIAN,
            User.activo == True
        )
        result = await self.session.execute(stmt)
        if not result.scalar_one_or_none():
            raise ValueError("Clínico no válido")

        patient.clinician_id = clinician_id
        await self.session.flush()
        return patient

    async def search(self, query: str, clinician_id: Optional[int] = None, limit: int = 20) -> List[Patient]:
        stmt = select(Patient).where(Patient.is_active == True).where(
            or_(
                Patient.first_name.ilike(f"%{query}%"),
                Patient.last_name.ilike(f"%{query}%"),
            )
        )
        if clinician_id:
            stmt = stmt.where(Patient.clinician_id == clinician_id)
        stmt = stmt.limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()


# =====================================================================
# VITAL SIGNS SERVICE
# =====================================================================

class VitalSignsService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def add_vital_signs(self, patient_id: int, data: dict) -> VitalSigns:
        stmt = select(Patient).where(Patient.id == patient_id)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if not patient:
            raise ValueError("Paciente no encontrado")

        data.pop("patient_id", None)
        if data.get("measured_at") is None:
            data.pop("measured_at", None)
            data["measured_at"] = datetime.now(timezone.utc)
        vitals = VitalSigns(patient_id=patient_id, **data)
        self.session.add(vitals)

        # Actualizar baseline
        if data.get("weight"):
            patient.baseline_weight = Decimal(str(data["weight"]))
        if data.get("height"):
            patient.baseline_height = Decimal(str(data["height"]))
        if data.get("bp_systolic"):
            patient.baseline_bp_systolic = data["bp_systolic"]
        if data.get("bp_diastolic"):
            patient.baseline_bp_diastolic = data["bp_diastolic"]
        if data.get("heart_rate"):
            patient.baseline_heart_rate = data["heart_rate"]
        if data.get("temperature"):
            patient.baseline_temperature = Decimal(str(data["temperature"]))
        if data.get("spo2"):
            patient.baseline_spo2 = data["spo2"]

        patient.vitals_updated_at = data.get("measured_at", datetime.now(timezone.utc))
        await self.session.flush()
        return vitals

    async def get_history(
        self,
        patient_id: int,
        days: int = 30,
        limit: int = 100,
        source: Optional[VitalSource] = None
    ) -> List[VitalSigns]:
        cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        stmt = select(VitalSigns).where(
            and_(
                VitalSigns.patient_id == patient_id,
                VitalSigns.measured_at >= cutoff
            )
        ).order_by(VitalSigns.measured_at.desc()).limit(limit)

        if source:
            stmt = stmt.where(VitalSigns.source == source)

        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_latest(self, patient_id: int) -> Optional[VitalSigns]:
        stmt = select(VitalSigns).where(VitalSigns.patient_id == patient_id).order_by(VitalSigns.measured_at.desc()).limit(1)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_trend(
        self,
        patient_id: int,
        parameter: str,
        days: int = 7
    ) -> List[dict]:
        valid_params = ["bp_systolic", "bp_diastolic", "heart_rate", "temperature", "spo2", "weight", "bmi"]
        if parameter not in valid_params:
            raise ValueError(f"Parámetro inválido. Válidos: {valid_params}")

        cutoff = datetime.now(timezone.utc) - timedelta(days=days)
        stmt = select(VitalSigns).where(
            and_(
                VitalSigns.patient_id == patient_id,
                VitalSigns.measured_at >= cutoff,
                getattr(VitalSigns, parameter).is_not(None)
            )
        ).order_by(VitalSigns.measured_at.asc())

        result = await self.session.execute(stmt)
        vitals = result.scalars().all()

        return [
            {"measured_at": v.measured_at.isoformat(), "value": float(getattr(v, parameter))}
            for v in vitals
        ]


# =====================================================================
# MEDICATION SERVICE
# =====================================================================

class MedicationService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, data: dict) -> Medication:
        med = Medication(**data)
        self.session.add(med)
        await self.session.flush()
        return med

    async def get_by_id(self, med_id: int) -> Optional[Medication]:
        stmt = select(Medication).where(Medication.id == med_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def search(
        self,
        query: str = "",
        therapeutic_class: Optional[str] = None,
        atc_prefix: Optional[str] = None,
        pregnancy_category: Optional[str] = None,
        status: str = "active",
        limit: int = 50,
        offset: int = 0
    ) -> List[Medication]:
        stmt = select(Medication).where(Medication.status == status)

        if query:
            stmt = stmt.where(
                or_(
                    Medication.generic_name.ilike(f"%{query}%"),
                    Medication.brand_names.contains([query.lower()]),
                    Medication.therapeutic_class.ilike(f"%{query}%")
                )
            )
        if therapeutic_class:
            stmt = stmt.where(Medication.therapeutic_class == therapeutic_class)
        if atc_prefix:
            stmt = stmt.where(Medication.atc_code.like(f"{atc_prefix}%"))
        if pregnancy_category:
            stmt = stmt.where(Medication.pregnancy_category == pregnancy_category)

        stmt = stmt.order_by(Medication.generic_name).offset(offset).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_therapeutic_classes(self) -> List[str]:
        stmt = select(Medication.therapeutic_class).distinct().where(Medication.status == "active")
        result = await self.session.execute(stmt)
        return [r[0] for r in result.all() if r[0]]

    async def check_interactions(self, medication_ids: List[int], patient_factors: Optional[dict] = None) -> dict:
        """Verificar interacciones entre lista de medicamentos."""
        interactions = []
        severity_counts = {"major": 0, "moderate": 0, "minor": 0, "contraindicated": 0}
        recommendations = []

        for i, id_a in enumerate(medication_ids):
            for id_b in medication_ids[i+1:]:
                stmt = select(DrugInteraction).where(
                    or_(
                        and_(DrugInteraction.medication_a_id == id_a, DrugInteraction.medication_b_id == id_b),
                        and_(DrugInteraction.medication_a_id == id_b, DrugInteraction.medication_b_id == id_a)
                    )
                ).options(
                    selectinload(DrugInteraction.medication_a),
                    selectinload(DrugInteraction.medication_b)
                )
                result = await self.session.execute(stmt)
                interaction = result.scalar_one_or_none()

                if interaction:
                    risk_factors_present = self._evaluate_risk_factors(
                        interaction.risk_factors, patient_factors or {}
                    )
                    adjusted_severity = self._adjust_severity(
                        interaction.severity, risk_factors_present
                    )

                    severity_counts[adjusted_severity] += 1

                    interactions.append({
                        "medication_a": {"id": interaction.medication_a.id, "name": interaction.medication_a.generic_name},
                        "medication_b": {"id": interaction.medication_b.id, "name": interaction.medication_b.generic_name},
                        "severity": adjusted_severity,
                        "original_severity": interaction.severity,
                        "mechanism": interaction.mechanism,
                        "clinical_effect": interaction.clinical_effect,
                        "management": interaction.management,
                        "evidence_level": interaction.evidence_level,
                        "risk_factors_present": risk_factors_present,
                        "references": interaction.references,
                    })

                    if adjusted_severity in ["major", "contraindicated"]:
                        recommendations.append(
                            f"⚠️ {interaction.medication_a.generic_name} + {interaction.medication_b.generic_name}: "
                            f"{interaction.management}"
                        )

        if severity_counts["contraindicated"] > 0:
            recommendations.insert(0, "🚨 CONTRAINDICACIÓN ABSOLUTA: Revisar terapia inmediatamente")
        elif severity_counts["major"] > 0:
            recommendations.insert(0, "⚠️ INTERACCIONES MAYORES: Requiere monitorización estrecha / ajuste dosis")

        return {
            "interactions": interactions,
            "summary": severity_counts,
            "recommendations": recommendations
        }

    def _evaluate_risk_factors(self, risk_factors: List[str], patient_factors: dict) -> List[str]:
        present = []
        age = patient_factors.get("age")
        crcl = patient_factors.get("crcl_ml_min")
        hepatic = patient_factors.get("hepatic_impairment")
        polypharmacy = patient_factors.get("medication_count", 0)

        for rf in risk_factors:
            rf_lower = rf.lower()
            if any(kw in rf_lower for kw in ["edad", "age", "anciano", "elderly", "mayor"]):
                if age and age >= 65:
                    present.append(rf)
            elif any(kw in rf_lower for kw in ["renal", "crcl", "creatinina"]):
                if crcl and crcl < 60:
                    present.append(rf)
            elif any(kw in rf_lower for kw in ["hepática", "hepatic", "hígado", "liver"]):
                if hepatic and hepatic != "none":
                    present.append(rf)
            elif any(kw in rf_lower for kw in ["polifarmacia", "polypharmacy"]):
                if polypharmacy >= 5:
                    present.append(rf)
        return present

    def _adjust_severity(self, base_severity: str, risk_factors: List[str]) -> str:
        if not risk_factors:
            return base_severity
        escalation = {
            "minor": "moderate",
            "moderate": "major",
            "major": "contraindicated",
            "contraindicated": "contraindicated"
        }
        severity = base_severity
        for _ in range(min(len(risk_factors), 2)):
            severity = escalation.get(severity, severity)
        return severity

    async def calculate_dosage(self, medication_id: int, patient_data: dict) -> dict:
        """Calcular dosis ajustada para paciente."""
        med = await self.get_by_id(medication_id)
        if not med:
            raise ValueError("Medicamento no encontrado")

        dosage_info = med.standard_dosage
        adjustments = []
        warnings = []

        base_dose = dosage_info.get("adult", {}).get("dose", "Ver ficha técnica")
        frequency = dosage_info.get("adult", {}).get("frequency", "Según indicación")
        max_dose = dosage_info.get("adult", {}).get("max_dose", "Ver ficha técnica")

        # Edad
        age = patient_data.get("age")
        if age is not None:
            if age < 18:
                ped_dose = dosage_info.get("pediatric")
                if ped_dose:
                    base_dose = ped_dose.get("dose", base_dose)
                    frequency = ped_dose.get("frequency", frequency)
                    max_dose = ped_dose.get("max_dose", max_dose)
                    adjustments.append(f"Dosis pediátrica (edad {age} años)")
                else:
                    warnings.append("⚠️ No hay dosis pediátrica estandarizada")
            elif age >= 65:
                elder_dose = dosage_info.get("elderly")
                if elder_dose:
                    base_dose = elder_dose.get("dose", base_dose)
                    frequency = elder_dose.get("frequency", frequency)
                    adjustments.append("Dosis ajustada para edad ≥ 65 años")

        # Peso
        weight = patient_data.get("weight_kg")
        if weight:
            w = float(weight)
            if w < 50:
                adjustments.append(f"Peso bajo ({w} kg): considerar reducción")
            elif w > 100:
                adjustments.append(f"Peso alto ({w} kg): verificar dosificación por peso")

        # Función renal
        crcl = patient_data.get("crcl_ml_min")
        if crcl is not None:
            crcl_f = float(crcl)
            renal_dosing = dosage_info.get("renal_impairment", {})
            if crcl_f < 15:
                key = "crcl_lt_15"
                adjustments.append(f"Insuficiencia renal severa (CrCl {crcl_f})")
                warnings.append("🚨 CrCl < 15: muchos fármacos contraindicados")
            elif crcl_f < 30:
                key = "crcl_15_30"
                adjustments.append(f"Insuficiencia renal moderada-severa (CrCl {crcl_f})")
            elif crcl_f < 50:
                key = "crcl_30_50"
                adjustments.append(f"Insuficiencia renal moderada (CrCl {crcl_f})")
            elif crcl_f < 80:
                key = "crcl_50_80"
                adjustments.append(f"Insuficiencia renal leve (CrCl {crcl_f})")
            else:
                key = None

            if key and key in renal_dosing:
                rec = renal_dosing[key]
                if rec == "contraindicated":
                    warnings.append(f"🚨 CONTRAINDICADO con CrCl {crcl_f}")
                else:
                    base_dose = rec
                    adjustments.append(f"Dosis renal ({key}): {rec}")

        # Hepática
        hepatic = patient_data.get("hepatic_impairment")
        if hepatic and hepatic != "none":
            hepatic_dosing = dosage_info.get("hepatic_impairment", {})
            if hepatic in hepatic_dosing:
                rec = hepatic_dosing[hepatic]
                if rec == "contraindicated":
                    warnings.append(f"🚨 CONTRAINDICADO en insuficiencia hepática {hepatic}")
                else:
                    base_dose = rec
                    adjustments.append(f"Dosis hepática ({hepatic}): {rec}")

        monitoring = list(med.monitoring_parameters or [])
        if crcl and float(crcl) < 60:
            monitoring = list(set(monitoring + ["Función renal", "Niveles séricos del fármaco"]))

        return {
            "medication_name": med.generic_name,
            "recommended_dose": str(base_dose),
            "frequency": frequency,
            "max_daily_dose": str(max_dose),
            "adjustments": adjustments,
            "monitoring": monitoring,
            "warnings": warnings
        }

    async def create_interaction(self, data: dict) -> DrugInteraction:
        interaction = DrugInteraction(**data)
        self.session.add(interaction)
        await self.session.flush()
        return interaction

    async def get_interactions_for_medication(self, med_id: int) -> List[DrugInteraction]:
        stmt = select(DrugInteraction).where(
            (DrugInteraction.medication_a_id == med_id) |
            (DrugInteraction.medication_b_id == med_id)
        ).options(
            selectinload(DrugInteraction.medication_a),
            selectinload(DrugInteraction.medication_b)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()


# =====================================================================
# PRESCRIPTION SERVICE
# =====================================================================

class PrescriptionService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.medication_service = MedicationService(session)

    async def create(self, patient_id: int, clinician_id: int, data: dict) -> Prescription:
        # Verificar paciente
        stmt = select(Patient).where(Patient.id == patient_id, Patient.is_active == True)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if not patient:
            raise ValueError("Paciente no encontrado o inactivo")

        # Verificar clínico
        stmt = select(User).where(
            User.id == clinician_id,
            User.rol == UserRole.CLINICIAN,
            User.activo == True
        )
        result = await self.session.execute(stmt)
        clinician = result.scalar_one_or_none()
        if not clinician:
            raise ValueError("Clínico no encontrado o inactivo")

        # Verificar medicamento
        medication_id = data.get("medication_id")
        medication = await self.medication_service.get_by_id(medication_id)
        if not medication:
            raise ValueError("Medicamento no encontrado")
        if medication.status != MedicationStatus.ACTIVE:
            raise ValueError("Medicamento no está activo")

        # Verificar duplicado
        stmt = select(Prescription).where(
            and_(
                Prescription.patient_id == patient_id,
                Prescription.medication_id == medication_id,
                Prescription.status.in_([PrescriptionStatus.ACTIVE, PrescriptionStatus.ON_HOLD])
            )
        )
        result = await self.session.execute(stmt)
        if result.scalar_one_or_none():
            raise ValueError("Ya existe prescripción activa para este medicamento")

        # Verificar alergias
        await self._check_allergies(patient, medication)

        # Verificar interacciones
        interaction_result = await self._check_interactions(patient, medication_id)
        if interaction_result["requires_confirmation"]:
            if interaction_result["summary"].get("contraindicated", 0) > 0:
                raise ValueError("CONTRAINDICACIÓN ABSOLUTA: " + "; ".join(interaction_result["recommendations"]))

        # Crear prescripción
        start_date = data.get("start_date", date.today())
        if isinstance(start_date, str):
            start_date = datetime.fromisoformat(start_date).date()
        duration_days = data.get("duration_days", 30)
        end_date = start_date + timedelta(days=duration_days)

        prescription = Prescription(
            patient_id=patient_id,
            clinician_id=clinician_id,
            medication_id=medication_id,
            dose=data["dose"],
            frequency=data["frequency"],
            route=data.get("route", "oral"),
            duration_days=duration_days,
            quantity=data["quantity"],
            refills_allowed=data.get("refills_allowed", 0),
            instructions=data.get("instructions"),
            indication=data.get("indication"),
            start_date=start_date,
            end_date=end_date,
        )
        self.session.add(prescription)

        # Sync patient medications
        await self._sync_patient_medications(patient)

        await self.session.flush()
        return prescription

    async def _check_allergies(self, patient: Patient, medication: Medication):
        patient_allergies = [a.lower().strip() for a in (patient.drug_allergies or [])]
        med_ingredients = [ing["name"].lower().strip() for ing in (medication.active_ingredients or [])]
        med_generic = medication.generic_name.lower().strip()

        for allergy in patient_allergies:
            if allergy in med_ingredients or allergy == med_generic:
                raise ValueError(f"ALERGIA: Paciente alérgico a '{allergy}' (presente en {medication.generic_name})")

    async def _check_interactions(self, patient: Patient, new_med_id: int) -> dict:
        current_med_ids = []
        for med in (patient.current_medications or []):
            if med.get("medication_id"):
                current_med_ids.append(med["medication_id"])

        if not current_med_ids:
            return {"interactions": [], "summary": {}, "recommendations": [], "can_proceed": True, "requires_confirmation": False}

        all_med_ids = current_med_ids + [new_med_id]
        patient_factors = {
            "age": patient.age,
            "crcl_ml_min": None,
            "hepatic_impairment": "none",
            "medication_count": len(current_med_ids),
        }

        from app.schemas.medication import InteractionCheckRequest
        request = InteractionCheckRequest(medication_ids=all_med_ids, patient_factors=patient_factors)
        result = await self.medication_service.check_interactions(request)

        return {
            "interactions": result["interactions"],
            "summary": result["summary"],
            "recommendations": result["recommendations"],
            "can_proceed": result["summary"].get("contraindicated", 0) == 0,
            "requires_confirmation": result["summary"].get("major", 0) > 0 or result["summary"].get("moderate", 0) > 2
        }

    async def _sync_patient_medications(self, patient: Patient):
        stmt = select(Prescription).where(
            and_(
                Prescription.patient_id == patient.id,
                Prescription.status == PrescriptionStatus.ACTIVE
            )
        ).options(selectinload(Prescription.medication))
        result = await self.session.execute(stmt)
        active_rx = result.scalars().all()

        patient.current_medications = [
            {
                "medication_id": rx.medication_id,
                "name": rx.medication.generic_name,
                "dose": rx.dose,
                "frequency": rx.frequency,
                "route": rx.route,
                "prescription_id": rx.id,
                "start_date": rx.start_date.isoformat(),
                "active": True
            }
            for rx in active_rx
        ]
        await self.session.flush()

    async def get_by_id(self, prescription_id: int) -> Optional[Prescription]:
        stmt = select(Prescription).where(Prescription.id == prescription_id).options(
            selectinload(Prescription.medication),
            selectinload(Prescription.patient),
            selectinload(Prescription.clinician)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_for_patient(
        self,
        patient_id: int,
        status: Optional[PrescriptionStatus] = None,
        skip: int = 0,
        limit: int = 50
    ) -> List[Prescription]:
        stmt = select(Prescription).where(Prescription.patient_id == patient_id)
        if status:
            stmt = stmt.where(Prescription.status == status)
        stmt = stmt.order_by(Prescription.created_at.desc()).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_active_for_patient(self, patient_id: int) -> List[Prescription]:
        return await self.list_for_patient(patient_id, status=PrescriptionStatus.ACTIVE)

    async def update(self, prescription: Prescription, data: dict) -> Prescription:
        update_data = data.copy()
        if "medication_id" in update_data:
            del update_data["medication_id"]

        for field, value in update_data.items():
            setattr(prescription, field, value)

        if "duration_days" in update_data or "start_date" in update_data:
            if prescription.duration_days and prescription.start_date:
                prescription.end_date = prescription.start_date + timedelta(days=prescription.duration_days)

        await self.session.flush()

        if "status" in update_data or "dose" in update_data or "frequency" in update_data:
            stmt = select(Patient).where(Patient.id == prescription.patient_id)
            result = await self.session.execute(stmt)
            patient = result.scalar_one_or_none()
            if patient:
                await self._sync_patient_medications(patient)

        return prescription

    async def dispense(self, prescription: Prescription, quantity: int) -> Prescription:
        if prescription.status != PrescriptionStatus.ACTIVE:
            raise ValueError("Solo se pueden dispensar prescripciones activas")

        prescription.dispensed_quantity += quantity
        prescription.refills_used += 1
        prescription.last_dispensed_at = datetime.now(timezone.utc)

        if prescription.refills_used >= prescription.refills_allowed:
            if prescription.duration_days:
                prescription.status = PrescriptionStatus.COMPLETED
            else:
                prescription.status = PrescriptionStatus.REFILL_EXHAUSTED

        stmt = select(Patient).where(Patient.id == prescription.patient_id)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if patient:
            await self._sync_patient_medications(patient)

        await self.session.flush()
        return prescription

    async def discontinue(self, prescription: Prescription, reason: str) -> Prescription:
        prescription.status = PrescriptionStatus.DISCONTINUED
        prescription.notes = (prescription.notes or "") + f"\n[{datetime.now(timezone.utc).isoformat()}] DISCONTINUED: {reason}"

        stmt = select(Patient).where(Patient.id == prescription.patient_id)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if patient:
            await self._sync_patient_medications(patient)

        await self.session.flush()
        return prescription

    async def check_interactions(self, prescription_id: int) -> dict:
        rx = await self.get_by_id(prescription_id)
        if not rx:
            raise ValueError("Prescripción no encontrada")

        stmt = select(Patient).where(Patient.id == rx.patient_id).options(selectinload(Patient.current_medications))
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()

        return await self._check_interactions(patient, rx.medication_id)


# =====================================================================
# EPISODE SERVICE
# =====================================================================

class EpisodeService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, patient_id: int, data: dict, creator: User) -> Episode:
        # Verificar acceso
        stmt = select(Patient).where(Patient.id == patient_id).options(selectinload(Patient.user))
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if not patient:
            raise ValueError("Paciente no encontrado")

        if creator.rol == UserRole.CLINICIAN and patient.clinician_id != creator.id:
            raise ValueError("No tiene acceso a este paciente")

        episode = Episode(
            patient_id=patient_id,
            clinician_id=patient.clinician_id,
            **data
        )
        self.session.add(episode)
        await self.session.flush()
        return episode

    async def get_detail(self, episode_id: int, user: User) -> Optional[Episode]:
        stmt = select(Episode).where(Episode.id == episode_id).options(
            selectinload(Episode.patient),
            selectinload(Episode.clinician),
            selectinload(Episode.notes).selectinload(ClinicalNote.author),
            selectinload(Episode.documents),
        )
        result = await self.session.execute(stmt)
        episode = result.scalar_one_or_none()
        if not episode:
            return None

        # Access check
        if user.rol == UserRole.CLINICIAN and episode.patient.clinician_id != user.id:
            return None
        elif user.rol == UserRole.PATIENT and episode.patient.user_id != user.id:
            return None

        return episode

    async def list_for_patient(
        self,
        patient_id: int,
        user: User,
        skip: int = 0,
        limit: int = 50,
        episode_type: Optional[EpisodeType] = None
    ) -> List[Episode]:
        # Access check
        stmt = select(Patient).where(Patient.id == patient_id)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if not patient:
            raise ValueError("Paciente no encontrado")

        if user.rol == UserRole.CLINICIAN and patient.clinician_id != user.id:
            raise ValueError("No tiene acceso a este paciente")
        elif user.rol == UserRole.PATIENT and patient.user_id != user.id:
            raise ValueError("No tiene acceso a este paciente")

        stmt = select(Episode).where(Episode.patient_id == patient_id)
        if episode_type:
            stmt = stmt.where(Episode.episode_type == episode_type)
        stmt = stmt.order_by(Episode.started_at.desc()).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def update(self, episode: Episode, data: dict, user: User) -> Episode:
        updates = data.copy()
        if "ended_at" in updates and updates["ended_at"]:
            episode.status = EpisodeStatus.CLOSED
        for field, value in updates.items():
            setattr(episode, field, value)
        await self.session.flush()
        return episode

    async def close(self, episode: Episode, user: User) -> Episode:
        if not episode.is_open:
            raise ValueError("Episodio ya está cerrado")
        episode.status = EpisodeStatus.CLOSED
        episode.ended_at = datetime.now(timezone.utc)
        await self.session.flush()
        return episode

    async def add_note(self, episode_id: int, data: dict, author: User) -> ClinicalNote:
        episode = await self._get_episode_check(episode_id, author)
        note = ClinicalNote(
            episode_id=episode_id,
            author_id=author.id,
            **data
        )
        self.session.add(note)
        await self.session.flush()
        return note

    async def sign_note(self, note: ClinicalNote, user: User) -> ClinicalNote:
        if note.author_id != user.id:
            raise ValueError("Solo el autor puede firmar la nota")
        if note.is_signed:
            raise ValueError("Nota ya firmada")
        note.is_signed = True
        note.signed_at = datetime.now(timezone.utc)
        await self.session.flush()
        return note

    async def list_notes(self, episode_id: int, user: User) -> List[ClinicalNote]:
        await self._get_episode_check(episode_id, user)
        stmt = select(ClinicalNote).where(ClinicalNote.episode_id == episode_id).order_by(ClinicalNote.created_at)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def add_document(self, data: dict, uploader: User) -> ClinicalDocument:
        episode = await self._get_episode_check(data["episode_id"], uploader)
        doc = ClinicalDocument(
            episode_id=data["episode_id"],
            uploaded_by=uploader.id,
            **data
        )
        self.session.add(doc)
        await self.session.flush()
        return doc

    async def list_documents(self, episode_id: int, user: User) -> List[ClinicalDocument]:
        await self._get_episode_check(episode_id, user)
        stmt = select(ClinicalDocument).where(ClinicalDocument.episode_id == episode_id).order_by(ClinicalDocument.created_at.desc())
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def _get_episode_check(self, episode_id: int, user: User) -> Episode:
        stmt = select(Episode).where(Episode.id == episode_id).options(selectinload(Episode.patient))
        result = await self.session.execute(stmt)
        episode = result.scalar_one_or_none()
        if not episode:
            raise ValueError("Episodio no encontrado")

        if user.rol == UserRole.CLINICIAN and episode.patient.clinician_id != user.id:
            raise ValueError("No tiene acceso a este paciente")
        elif user.rol == UserRole.PATIENT and episode.patient.user_id != user.id:
            raise ValueError("No tiene acceso a este paciente")

        return episode


# =====================================================================
# CLINICAL TIMELINE SERVICE
# =====================================================================

class ClinicalTimelineService:
    """Timeline unificado: episodes + notes + documents + vitals + prescriptions."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_timeline(
        self,
        patient_id: int,
        user: User,
        limit: int = 100
    ) -> dict:
        # Access check
        stmt = select(Patient).where(Patient.id == patient_id)
        result = await self.session.execute(stmt)
        patient = result.scalar_one_or_none()
        if not patient:
            raise ValueError("Paciente no encontrado")

        if user.rol == UserRole.CLINICIAN and patient.clinician_id != user.id:
            raise ValueError("No tiene acceso a este paciente")
        elif user.rol == UserRole.PATIENT and patient.user_id != user.id:
            raise ValueError("No tiene acceso a este paciente")

        # Queries paralelas
        episodes_stmt = select(Episode).where(Episode.patient_id == patient_id).order_by(Episode.started_at.desc()).limit(limit)
        notes_stmt = select(ClinicalNote).join(Episode).where(Episode.patient_id == patient_id).order_by(ClinicalNote.created_at.desc()).limit(limit)
        docs_stmt = select(ClinicalDocument).join(Episode).where(Episode.patient_id == patient_id).order_by(ClinicalDocument.created_at.desc()).limit(limit)

        episodes = (await self.session.execute(episodes_stmt)).scalars().all()
        notes = (await self.session.execute(notes_stmt)).scalars().all()
        docs = (await self.session.execute(docs_stmt)).scalars().all()

        # Vitals y prescriptions (usando services)
        vitals_service = VitalSignsService(self.session)
        vitals = await vitals_service.get_history(patient_id, days=365*5, limit=limit)

        rx_service = PrescriptionService(self.session)
        prescriptions = await rx_service.get_active_for_patient(patient_id)

        return {
            "patient_id": patient_id,
            "summary": {
                "episodes": len(episodes),
                "notes": len(notes),
                "documents": len(docs),
                "vitals_records": len(vitals),
                "active_prescriptions": len(prescriptions),
            },
            "episodes": [
                {"id": e.id, "type": e.episode_type, "status": e.status, "started_at": e.started_at, "chief_complaint": e.chief_complaint}
                for e in episodes
            ],
            "notes": [
                {"id": n.id, "type": n.note_type, "created_at": n.created_at, "author_id": n.author_id, "title": n.title}
                for n in notes
            ],
            "documents": [
                {"id": d.id, "type": d.document_type, "created_at": d.created_at, "filename": d.filename, "size_bytes": d.size_bytes}
                for d in docs
            ],
            "vitals": [
                {"id": v.id, "measured_at": v.measured_at, "source": v.source.value, "bmi": float(v.bmi) if v.bmi else None}
                for v in vitals
            ],
            "prescriptions": [
                {"id": p.id, "medication": p.medication.generic_name, "dose": p.dose, "status": p.status.value}
                for p in prescriptions
            ],
        }