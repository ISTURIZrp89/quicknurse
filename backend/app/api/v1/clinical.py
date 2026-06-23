from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional, List
from datetime import date

from app.database import get_async_db
from app.models import User, UserRole, Patient, VitalSource, VitalSigns
from app.services.clinical import (
    PatientService, VitalSignsService, MedicationService,
    PrescriptionService, EpisodeService, ClinicalTimelineService
)
from app.security import get_current_user, RefreshRequest
from app.schemas.clinical import (
    PatientCreate, PatientUpdate, PatientResponse, PatientListResponse, PatientSearchResponse,
    VitalSignsCreate, VitalSignsResponse, VitalSignsTrendResponse,
    MedicationSearchResponse, MedicationDetailResponse, DrugInteractionResponse, InteractionMedicationRef,
    InteractionCheckRequest, DosageCalculateRequest,
    PrescriptionCreate, PrescriptionUpdate, PrescriptionResponse, PrescriptionListResponse, PrescriptionMedicationRef,
    PrescriptionDispenseResponse,
    EpisodeCreate, EpisodeUpdate, EpisodeResponse, EpisodeListResponse,
    ClinicalNoteCreate, ClinicalNoteResponse,
    ClinicalDocumentCreate, ClinicalDocumentResponse,
    TimelineEntry,
)
from sqlalchemy import select

# Placeholder for policy - implementar RBAC completo según blueprint
class Policy:
    def __init__(self, user: User):
        self.user = user

async def get_policy(db: AsyncSession = Depends(get_async_db), current_user: str = Depends(get_current_user)) -> Policy:
    stmt = select(User).where(User.username == current_user)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(401, "Usuario no encontrado")
    return Policy(user)

# =====================================================================
# MAIN CLINICAL ROUTER (no prefix)
# =====================================================================

router = APIRouter(tags=["clinical"])

# =====================================================================
# PATIENTS ROUTER (prefix="/patients")
# =====================================================================

patients_router = APIRouter(prefix="/patients", tags=["patients"])

@patients_router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_patient(
    data: PatientCreate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PatientService(db)
    try:
        patient = await svc.create(data.model_dump(), policy.user)
        await db.commit()
        return {"id": patient.id, "full_name": patient.full_name, "age": patient.age}
    except ValueError as e:
        raise HTTPException(400, str(e))

@patients_router.get("", response_model=List[PatientListResponse])
async def list_patients(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    active_only: bool = True,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PatientService(db)
    clinician_id = None
    if policy.user.rol == UserRole.CLINICIAN:
        clinician_id = policy.user.id
    elif policy.user.rol == UserRole.PATIENT:
        patient = await svc.get_by_user_id(policy.user.id)
        return [PatientListResponse(id=patient.id, full_name=patient.full_name, age=patient.age, is_active=patient.is_active, clinician_id=patient.clinician_id, created_at=patient.created_at)] if patient else []

    patients = await svc.list_patients(clinician_id=clinician_id, active_only=active_only, skip=skip, limit=limit)
    return [
        PatientListResponse(id=p.id, full_name=p.full_name, age=p.age, is_active=p.is_active, clinician_id=p.clinician_id, created_at=p.created_at)
        for p in patients
    ]

@patients_router.get("/search", response_model=List[PatientSearchResponse])
async def search_patients(
    q: str = Query(..., min_length=2),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    if policy.user.rol == UserRole.PATIENT:
        raise HTTPException(403, "Sin acceso")
    svc = PatientService(db)
    clinician_id = policy.user.id if policy.user.rol == UserRole.CLINICIAN else None
    patients = await svc.search(q, clinician_id=clinician_id, limit=limit)
    return [
        PatientSearchResponse(id=p.id, full_name=p.full_name, age=p.age)
        for p in patients
    ]

@patients_router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient(
    patient_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PatientService(db)
    patient = await svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "No encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    return PatientResponse(
        id=patient.id,
        first_name=patient.first_name,
        last_name=patient.last_name,
        full_name=patient.full_name,
        age=patient.age,
        date_of_birth=patient.date_of_birth,
        sex=patient.sex.value,
        blood_type=patient.blood_type.value,
        phone=patient.phone,
        emergency_contact_name=patient.emergency_contact_name,
        emergency_contact_phone=patient.emergency_contact_phone,
        allergies=patient.allergies,
        drug_allergies=patient.drug_allergies,
        chronic_conditions=patient.chronic_conditions,
        current_medications=patient.current_medications,
        surgical_history=patient.surgical_history,
        family_history=patient.family_history,
        immunizations=patient.immunizations,
        baseline_bp_systolic=patient.baseline_bp_systolic,
        baseline_bp_diastolic=patient.baseline_bp_diastolic,
        baseline_heart_rate=patient.baseline_heart_rate,
        baseline_temperature=float(patient.baseline_temperature) if patient.baseline_temperature else None,
        baseline_spo2=patient.baseline_spo2,
        baseline_weight=float(patient.baseline_weight) if patient.baseline_weight else None,
        baseline_height=float(patient.baseline_height) if patient.baseline_height else None,
        bmi=patient.bmi,
        vitals_updated_at=patient.vitals_updated_at,
        smoking_status=patient.smoking_status,
        alcohol_use=patient.alcohol_use,
        occupation=patient.occupation,
        is_active=patient.is_active,
        created_at=patient.created_at,
        updated_at=patient.updated_at,
    )

@patients_router.patch("/{patient_id}", response_model=dict)
async def update_patient(
    patient_id: int,
    data: PatientUpdate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PatientService(db)
    patient = await svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "No encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "No puede modificar pacientes de otro clínico")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    try:
        updated = await svc.update(patient, data.model_dump(exclude_unset=True))
        await db.commit()
        return {"id": updated.id, "full_name": updated.full_name, "message": "Actualizado correctamente"}
    except ValueError as e:
        raise HTTPException(400, str(e))

# =====================================================================
# VITAL SIGNS ROUTER (nested under patients)
# =====================================================================

vitals_router = APIRouter(prefix="/{patient_id}/vitals", tags=["vital_signs"])

@vitals_router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def add_vital_signs(
    patient_id: int,
    data: VitalSignsCreate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = VitalSignsService(db)
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    try:
        vitals = await svc.add_vital_signs(patient_id, data.model_dump())
        await db.commit()
        return {"id": vitals.id, "measured_at": vitals.measured_at, "message": "Signos vitales registrados"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@vitals_router.get("", response_model=List[VitalSignsResponse])
async def get_vitals_history(
    patient_id: int,
    days: int = Query(30, ge=1, le=365),
    limit: int = Query(100, ge=1, le=500),
    source: Optional[VitalSource] = None,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = VitalSignsService(db)
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    vitals = await svc.get_history(patient_id, days=days, limit=limit, source=source)
    return [
        VitalSignsResponse(
            id=v.id,
            measured_at=v.measured_at,
            bp_systolic=v.bp_systolic,
            bp_diastolic=v.bp_diastolic,
            heart_rate=v.heart_rate,
            temperature=float(v.temperature) if v.temperature else None,
            spo2=v.spo2,
            respiratory_rate=v.respiratory_rate,
            weight=float(v.weight) if v.weight else None,
            height=float(v.height) if v.height else None,
            bmi=float(v.bmi) if v.bmi else None,
            source=v.source.value,
        )
        for v in vitals
    ]

@vitals_router.get("/latest", response_model=VitalSignsResponse)
async def get_latest_vitals(
    patient_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = VitalSignsService(db)
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    vitals = await svc.get_latest(patient_id)
    if not vitals:
        raise HTTPException(404, "No hay signos vitales registrados")
    return VitalSignsResponse(
        id=vitals.id,
        measured_at=vitals.measured_at,
        bp_systolic=vitals.bp_systolic,
        bp_diastolic=vitals.bp_diastolic,
        heart_rate=vitals.heart_rate,
        temperature=float(vitals.temperature) if vitals.temperature else None,
        spo2=vitals.spo2,
        respiratory_rate=vitals.respiratory_rate,
        weight=float(vitals.weight) if vitals.weight else None,
        height=float(vitals.height) if vitals.height else None,
        bmi=float(vitals.bmi) if vitals.bmi else None,
        source=vitals.source.value,
    )

@vitals_router.get("/trend", response_model=VitalSignsTrendResponse)
async def get_vitals_trend(
    patient_id: int,
    parameter: str = Query(..., description="bp_systolic|bp_diastolic|heart_rate|temperature|spo2|weight|bmi"),
    days: int = Query(7, ge=1, le=90),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = VitalSignsService(db)
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    try:
        data = await svc.get_trend(patient_id, parameter, days)
        return VitalSignsTrendResponse(parameter=parameter, data=data, days=days)
    except ValueError as e:
        raise HTTPException(400, str(e))

# Include vitals_router in patients_router (nested)
patients_router.include_router(vitals_router)

# Include patients_router in main router
router.include_router(patients_router)

# =====================================================================
# MEDICATIONS ROUTER (top level, prefix="/medications")
# =====================================================================

meds_router = APIRouter(prefix="/medications", tags=["medications"])

@meds_router.get("/therapeutic-classes", response_model=List[str])
async def get_therapeutic_classes(
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = MedicationService(db)
    return await svc.get_therapeutic_classes()

@meds_router.get("", response_model=List[MedicationSearchResponse])
async def search_medications(
    q: str = Query("", min_length=0),
    therapeutic_class: Optional[str] = None,
    atc_prefix: Optional[str] = None,
    pregnancy_category: Optional[str] = None,
    status: str = Query("active", max_length=20),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = MedicationService(db)
    meds = await svc.search(
        query=q, therapeutic_class=therapeutic_class, atc_prefix=atc_prefix,
        pregnancy_category=pregnancy_category, status=status, limit=limit, offset=offset
    )
    return [
        MedicationSearchResponse(
            id=m.id,
            generic_name=m.generic_name,
            brand_names=m.brand_names,
            atc_code=m.atc_code,
            therapeutic_class=m.therapeutic_class,
            pharmacological_class=m.pharmacological_class,
            pregnancy_category=m.pregnancy_category.value,
            lactation_category=m.lactation_category.value,
            is_controlled=m.is_controlled,
        )
        for m in meds
    ]

@meds_router.get("/{med_id}", response_model=MedicationDetailResponse)
async def get_medication(
    med_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = MedicationService(db)
    med = await svc.get_by_id(med_id)
    if not med:
        raise HTTPException(404, "Medicamento no encontrado")

    interactions = await svc.get_interactions_for_medication(med_id)

    return MedicationDetailResponse(
        id=med.id,
        generic_name=med.generic_name,
        brand_names=med.brand_names,
        atc_code=med.atc_code,
        atc_levels=med.atc_levels,
        therapeutic_class=med.therapeutic_class,
        pharmacological_class=med.pharmacological_class,
        active_ingredients=med.active_ingredients,
        presentations=med.presentations,
        standard_dosage=med.standard_dosage,
        indications=med.indications,
        contraindications=med.contraindications,
        precautions=med.precautions,
        pregnancy_category=med.pregnancy_category.value,
        lactation_category=med.lactation_category.value,
        half_life_hours=float(med.half_life_hours) if med.half_life_hours else None,
        bioavailability=med.bioavailability,
        protein_binding=med.protein_binding,
        metabolism=med.metabolism,
        excretion=med.excretion,
        monitoring_parameters=med.monitoring_parameters,
        status=med.status.value,
        is_controlled=med.is_controlled,
        controlled_schedule=med.controlled_schedule,
        interactions=[
            DrugInteractionResponse(
                id=i.id,
                severity=i.severity,
                mechanism=i.mechanism,
                clinical_effect=i.clinical_effect,
                management=i.management,
                evidence_level=i.evidence_level,
                references=i.references,
                risk_factors=i.risk_factors,
                is_bidirectional=i.is_bidirectional,
                other_medication=InteractionMedicationRef(
                    id=i.medication_b.id,
                    name=i.medication_b.generic_name
                ) if i.medication_a_id == med_id else InteractionMedicationRef(
                    id=i.medication_a.id,
                    name=i.medication_a.generic_name
                )
            )
            for i in interactions
        ]
    )

@meds_router.post("/interactions/check", response_model=dict)
async def check_interactions(
    request: InteractionCheckRequest,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = MedicationService(db)
    return await svc.check_interactions(request)

@meds_router.post("/dosage/calculate", response_model=dict)
async def calculate_dosage(
    request: DosageCalculateRequest,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = MedicationService(db)
    try:
        return await svc.calculate_dosage(request.medication_id, request.patient_data)
    except ValueError as e:
        raise HTTPException(400, str(e))

# Include meds_router in main router (top level)
router.include_router(meds_router)

# =====================================================================
# PRESCRIPTIONS ROUTER (top level, prefix="/patients/{patient_id}/prescriptions")
# =====================================================================

rx_router = APIRouter(prefix="/patients/{patient_id}/prescriptions", tags=["prescriptions"])

@rx_router.post("", status_code=status.HTTP_201_CREATED)
async def create_prescription(
    patient_id: int,
    data: PrescriptionCreate,
    confirm: bool = Query(False, description="Confirmar a pesar de interacciones"),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "No tiene acceso a este paciente")

    svc = PrescriptionService(db)
    try:
        interaction_check = await svc._check_interactions(patient, data.medication_id)
        if interaction_check["requires_confirmation"] and not confirm:
            raise HTTPException(
                status_code=409,
                detail={
                    "message": "Interacciones detectadas - confirmación requerida",
                    "interactions": interaction_check["interactions"],
                    "recommendations": interaction_check["recommendations"],
                    "requires_confirmation": True
                }
            )

        prescription = await svc.create(patient_id, policy.user.id, data.model_dump())
        await db.commit()
        return {"id": prescription.id, "message": "Prescripción creada"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@rx_router.get("", response_model=List[PrescriptionListResponse])
async def list_prescriptions(
    patient_id: int,
    status: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    svc = PrescriptionService(db)
    rx_status = status and (
        getattr(__import__('app.models', fromlist=['PrescriptionStatus']), 'PrescriptionStatus')(status)
        if status else None
    )
    prescriptions = await svc.list_for_patient(patient_id, status=rx_status, skip=skip, limit=limit)
    return [
        PrescriptionListResponse(
            id=p.id,
            medication_name=p.medication.generic_name,
            dose=p.dose,
            frequency=p.frequency,
            status=p.status.value,
            start_date=p.start_date,
            end_date=p.end_date,
            days_remaining=p.days_remaining,
            refills_remaining=p.refills_remaining,
        )
        for p in prescriptions
    ]

@rx_router.get("/active", response_model=List[PrescriptionListResponse])
async def list_active_prescriptions(
    patient_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    patient_svc = PatientService(db)
    patient = await patient_svc.get_by_id(patient_id)
    if not patient:
        raise HTTPException(404, "Paciente no encontrado")

    if policy.user.rol == UserRole.CLINICIAN and patient.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    svc = PrescriptionService(db)
    prescriptions = await svc.get_active_for_patient(patient_id)
    return [
        PrescriptionListResponse(
            id=p.id,
            medication_name=p.medication.generic_name,
            dose=p.dose,
            frequency=p.frequency,
            status=p.status.value,
            start_date=p.start_date,
            end_date=p.end_date,
            days_remaining=p.days_remaining,
            refills_remaining=p.refills_remaining,
        )
        for p in prescriptions
    ]

@rx_router.get("/{rx_id}", response_model=PrescriptionResponse)
async def get_prescription(
    patient_id: int,
    rx_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PrescriptionService(db)
    rx = await svc.get_by_id(rx_id)
    if not rx or rx.patient_id != patient_id:
        raise HTTPException(404, "Prescripción no encontrada")

    if policy.user.rol == UserRole.CLINICIAN and rx.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and rx.patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    return PrescriptionResponse(
        id=rx.id,
        medication=PrescriptionMedicationRef(id=rx.medication.id, generic_name=rx.medication.generic_name, therapeutic_class=rx.medication.therapeutic_class),
        dose=rx.dose,
        frequency=rx.frequency,
        route=rx.route,
        duration_days=rx.duration_days,
        quantity=rx.quantity,
        refills_allowed=rx.refills_allowed,
        refills_used=rx.refills_used,
        refills_remaining=rx.refills_remaining,
        instructions=rx.instructions,
        indication=rx.indication,
        status=rx.status.value,
        start_date=rx.start_date,
        end_date=rx.end_date,
        days_remaining=rx.days_remaining,
        last_dispensed_at=rx.last_dispensed_at,
        dispensed_quantity=rx.dispensed_quantity,
        clinician_id=rx.clinician_id,
        created_at=rx.created_at,
        updated_at=rx.updated_at,
    )

@rx_router.patch("/{rx_id}", response_model=dict)
async def update_prescription(
    patient_id: int,
    rx_id: int,
    data: PrescriptionUpdate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PrescriptionService(db)
    rx = await svc.get_by_id(rx_id)
    if not rx or rx.patient_id != patient_id:
        raise HTTPException(404, "Prescripción no encontrada")

    if policy.user.rol == UserRole.CLINICIAN and rx.clinician_id != policy.user.id:
        raise HTTPException(403, "No puede modificar prescripciones de otro clínico")
    elif policy.user.rol == UserRole.PATIENT:
        raise HTTPException(403, "Solo clínicos pueden modificar prescripciones")

    try:
        updated = await svc.update(rx, data.model_dump(exclude_unset=True))
        await db.commit()
        return {"id": updated.id, "message": "Prescripción actualizada"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@rx_router.post("/{rx_id}/dispense", response_model=PrescriptionDispenseResponse)
async def dispense_prescription(
    patient_id: int,
    rx_id: int,
    quantity: int = Query(..., gt=0),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PrescriptionService(db)
    rx = await svc.get_by_id(rx_id)
    if not rx or rx.patient_id != patient_id:
        raise HTTPException(404, "Prescripción no encontrada")

    try:
        dispensed = await svc.dispense(rx, quantity)
        await db.commit()
        return PrescriptionDispenseResponse(
            id=dispensed.id,
            dispensed_quantity=dispensed.dispensed_quantity,
            refills_used=dispensed.refills_used,
            refills_remaining=dispensed.refills_remaining,
            status=dispensed.status.value,
            last_dispensed_at=dispensed.last_dispensed_at,
        )
    except ValueError as e:
        raise HTTPException(400, str(e))

@rx_router.post("/{rx_id}/discontinue", response_model=dict)
async def discontinue_prescription(
    patient_id: int,
    rx_id: int,
    reason: str,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PrescriptionService(db)
    rx = await svc.get_by_id(rx_id)
    if not rx or rx.patient_id != patient_id:
        raise HTTPException(404, "Prescripción no encontrada")

    try:
        discontinued = await svc.discontinue(rx, reason)
        await db.commit()
        return {"id": discontinued.id, "status": discontinued.status.value, "message": "Prescripción discontinuada"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@rx_router.get("/{rx_id}/interactions", response_model=dict)
async def check_prescription_interactions(
    patient_id: int,
    rx_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = PrescriptionService(db)
    rx = await svc.get_by_id(rx_id)
    if not rx or rx.patient_id != patient_id:
        raise HTTPException(404, "Prescripción no encontrada")

    if policy.user.rol == UserRole.CLINICIAN and rx.clinician_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")
    elif policy.user.rol == UserRole.PATIENT and rx.patient.user_id != policy.user.id:
        raise HTTPException(403, "Sin acceso")

    result = await svc.check_interactions(rx_id)
    return result

# Include rx_router in main router (top level)
router.include_router(rx_router)

# =====================================================================
# EPISODES ROUTER (top level, prefix="/episodes")
# =====================================================================

episodes_router = APIRouter(prefix="/episodes", tags=["episodes"])

@episodes_router.post("/patients/{patient_id}", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_episode(
    patient_id: int,
    data: EpisodeCreate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    try:
        episode = await svc.create(patient_id, data.model_dump(), policy.user)
        await db.commit()
        detail = await svc.get_detail(episode.id, policy.user)
        return {"id": detail.id, "episode_type": detail.episode_type, "chief_complaint": detail.chief_complaint}
    except ValueError as e:
        raise HTTPException(400, str(e))

@episodes_router.get("/patients/{patient_id}", response_model=List[EpisodeListResponse])
async def list_episodes(
    patient_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    episode_type: Optional[str] = None,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    ep_type = EpisodeType(episode_type) if episode_type else None
    episodes = await svc.list_for_patient(patient_id, policy.user, skip=skip, limit=limit, episode_type=ep_type)
    return [
        EpisodeListResponse(
            id=e.id,
            episode_type=e.episode_type,
            status=e.status.value,
            started_at=e.started_at,
            ended_at=e.ended_at,
            chief_complaint=e.chief_complaint,
            is_open=e.is_open,
        )
        for e in episodes
    ]

@episodes_router.get("/patients/{patient_id}/timeline", response_model=dict)
async def get_timeline(
    patient_id: int,
    limit: int = Query(100, ge=1, le=500),
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = ClinicalTimelineService(db)
    return await svc.get_timeline(patient_id, policy.user, limit=limit)

@episodes_router.get("/{episode_id}", response_model=EpisodeResponse)
async def get_episode(
    episode_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    episode = await svc.get_detail(episode_id, policy.user)
    if not episode:
        raise HTTPException(404, "Episodio no encontrado")
    return EpisodeResponse(
        id=episode.id,
        patient_id=episode.patient_id,
        clinician_id=episode.clinician_id,
        episode_type=episode.episode_type,
        status=episode.status.value,
        started_at=episode.started_at,
        ended_at=episode.ended_at,
        scheduled_at=episode.scheduled_at,
        location=episode.location,
        department=episode.department,
        chief_complaint=episode.chief_complaint,
        reason_for_visit=episode.reason_for_visit,
        subjective=episode.subjective,
        objective=episode.objective,
        assessment=episode.assessment,
        plan=episode.plan,
        diagnoses=episode.diagnoses,
        procedures=episode.procedures,
        is_billable=episode.is_billable,
        requires_followup=episode.requires_followup,
        followup_notes=episode.followup_notes,
        created_at=episode.created_at,
        updated_at=episode.updated_at,
        is_open=episode.is_open,
    )

@episodes_router.patch("/{episode_id}", response_model=dict)
async def update_episode(
    episode_id: int,
    data: EpisodeUpdate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    episode = await svc.get_detail(episode_id, policy.user)
    if not episode:
        raise HTTPException(404, "Episodio no encontrado")
    try:
        updated = await svc.update(episode, data.model_dump(exclude_unset=True), policy.user)
        await db.commit()
        detail = await svc.get_detail(episode.id, policy.user)
        return {"id": detail.id, "message": "Episodio actualizado"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@episodes_router.post("/{episode_id}/close", response_model=dict)
async def close_episode(
    episode_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    episode = await svc.get_detail(episode_id, policy.user)
    if not episode:
        raise HTTPException(404, "Episodio no encontrado")
    try:
        closed = await svc.close(episode, policy.user)
        await db.commit()
        detail = await svc.get_detail(episode.id, policy.user)
        return {"id": detail.id, "status": detail.status.value, "message": "Episodio cerrado"}
    except ValueError as e:
        raise HTTPException(400, str(e))

# --- Notes ---
notes_router = APIRouter(prefix="/{episode_id}/notes", tags=["clinical_notes"])

@notes_router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_note(
    episode_id: int,
    data: ClinicalNoteCreate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    try:
        note = await svc.add_note(episode_id, data.model_dump(), policy.user)
        await db.commit()
        return {"id": note.id, "note_type": note.note_type, "message": "Nota creada"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@notes_router.get("", response_model=List[ClinicalNoteResponse])
async def list_notes(
    episode_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    notes = await svc.list_notes(episode_id, policy.user)
    return [
        ClinicalNoteResponse(
            id=n.id,
            note_type=n.note_type,
            title=n.title,
            content=n.content,
            structured_data=n.structured_data,
            is_signed=n.is_signed,
            signed_at=n.signed_at,
            author_id=n.author_id,
            created_at=n.created_at,
            updated_at=n.updated_at,
        )
        for n in notes
    ]

@notes_router.post("/{note_id}/sign", response_model=dict)
async def sign_note(
    episode_id: int,
    note_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    stmt = select(ClinicalNote).where(ClinicalNote.id == note_id, ClinicalNote.episode_id == episode_id)
    result = await db.execute(stmt)
    note = result.scalar_one_or_none()
    if not note:
        raise HTTPException(404, "Nota no encontrada")

    try:
        signed = await svc.sign_note(note, policy.user)
        await db.commit()
        return {"id": signed.id, "is_signed": signed.is_signed, "signed_at": signed.signed_at, "message": "Nota firmada"}
    except ValueError as e:
        raise HTTPException(400, str(e))

episodes_router.include_router(notes_router)

# --- Documents ---
docs_router = APIRouter(prefix="/{episode_id}/documents", tags=["clinical_documents"])

@docs_router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def upload_document(
    episode_id: int,
    data: ClinicalDocumentCreate,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    try:
        doc = await svc.add_document(data.model_dump(), policy.user)
        await db.commit()
        return {"id": doc.id, "filename": doc.filename, "message": "Documento subido"}
    except ValueError as e:
        raise HTTPException(400, str(e))

@docs_router.get("", response_model=List[ClinicalDocumentResponse])
async def list_documents(
    episode_id: int,
    db: AsyncSession = Depends(get_async_db),
    policy: Policy = Depends(get_policy)
):
    svc = EpisodeService(db)
    docs = await svc.list_documents(episode_id, policy.user)
    return [
        ClinicalDocumentResponse(
            id=d.id,
            filename=d.filename,
            original_filename=d.original_filename,
            mime_type=d.mime_type,
            size_bytes=d.size_bytes,
            document_type=d.document_type,
            description=d.description,
            created_at=d.created_at,
        )
        for d in docs
    ]

episodes_router.include_router(docs_router)

# Include episodes_router in main router (top level)
router.include_router(episodes_router)