from sqlalchemy import Column, Integer, String, Float, Boolean, Text, BigInteger, DateTime, ForeignKey, JSON, Enum, Numeric, Date, Index, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import enum
from datetime import datetime, timezone, timedelta


# =====================================================================
# ENUMS
# =====================================================================

class UserRole(str, enum.Enum):
    ADMIN = "admin"
    CLINICIAN = "clinician"
    PATIENT = "patient"


class BloodType(str, enum.Enum):
    A_POS = "A+"
    A_NEG = "A-"
    B_POS = "B+"
    B_NEG = "B-"
    AB_POS = "AB+"
    AB_NEG = "AB-"
    O_POS = "O+"
    O_NEG = "O-"
    UNKNOWN = "unknown"


class Sex(str, enum.Enum):
    MALE = "M"
    FEMALE = "F"
    OTHER = "O"


class EpisodeType(str, enum.Enum):
    EMERGENCY = "emergency"
    CONSULTATION = "consultation"
    HOSPITALIZATION = "hospitalization"
    TELEMEDICINE = "telemedicine"
    HOME_VISIT = "home_visit"
    PREOPERATIVE = "preoperative"
    POSTOPERATIVE = "postoperative"
    FOLLOWUP = "followup"
    SCREENING = "screening"
    VACCINATION = "vaccination"


class EpisodeStatus(str, enum.Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    CLOSED = "closed"
    CANCELLED = "cancelled"
    REFERRED = "referred"


class MedicationStatus(str, enum.Enum):
    ACTIVE = "active"
    DISCONTINUED = "discontinued"
    EXPERIMENTAL = "experimental"
    WITHDRAWN = "withdrawn"


class PregnancyCategory(str, enum.Enum):
    A = "A"
    B = "B"
    C = "C"
    D = "D"
    X = "X"
    N = "N"


class LactationCategory(str, enum.Enum):
    L1 = "L1"
    L2 = "L2"
    L3 = "L3"
    L4 = "L4"
    L5 = "L5"


class PrescriptionStatus(str, enum.Enum):
    ACTIVE = "active"
    COMPLETED = "completed"
    DISCONTINUED = "discontinued"
    ON_HOLD = "on_hold"
    EXPIRED = "expired"
    REFILL_EXHAUSTED = "refill_exhausted"


# =====================================================================
# USER MODEL (extended with 2FA)
# =====================================================================

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    password_hash = Column(String(200), nullable=False)
    email = Column(String(200), unique=True, nullable=True, index=True)
    nombre_completo = Column(String(200), nullable=True)
    rol = Column(Enum(UserRole), default=UserRole.CLINICIAN, nullable=False)
    activo = Column(Boolean, default=True, nullable=False)
    creado_en = Column(DateTime, server_default=func.now())
    ultimo_acceso = Column(DateTime, nullable=True)

    # 2FA fields
    totp_secret = Column(String(32), nullable=True)
    totp_enabled = Column(Boolean, default=False, nullable=False)
    backup_codes = Column(JSON, default=list, nullable=False)

    # Relationships
    patient_profile = relationship("Patient", back_populates="user", foreign_keys="Patient.user_id", uselist=False, cascade="all, delete-orphan")
    patients = relationship("Patient", back_populates="clinician", foreign_keys="Patient.clinician_id")
    episodes = relationship("Episode", back_populates="clinician")
    prescriptions = relationship("Prescription", back_populates="clinician", foreign_keys="Prescription.clinician_id")
    clinical_notes = relationship("ClinicalNote", back_populates="author")
    uploaded_documents = relationship("ClinicalDocument", back_populates="uploader")


# =====================================================================
# PATIENT MODEL (Module 3.1)
# =====================================================================

class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, autoincrement=True)

    # Ownership
    user_id = Column(ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    clinician_id = Column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)

    # Demographics
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False, index=True)
    sex = Column(Enum(Sex), nullable=False)
    blood_type = Column(Enum(BloodType), default=BloodType.UNKNOWN, nullable=False)

    # Contact
    phone = Column(String(30), nullable=True)
    emergency_contact_name = Column(String(200), nullable=True)
    emergency_contact_phone = Column(String(30), nullable=True)

    # Clinical Profile
    allergies = Column(JSON, default=list, nullable=False)
    drug_allergies = Column(JSON, default=list, nullable=False)
    chronic_conditions = Column(JSON, default=list, nullable=False)
    current_medications = Column(JSON, default=list, nullable=False)
    surgical_history = Column(JSON, default=list, nullable=False)
    family_history = Column(JSON, default=list, nullable=False)
    immunizations = Column(JSON, default=list, nullable=False)

    # Baseline Vitals
    baseline_bp_systolic = Column(Integer, nullable=True)
    baseline_bp_diastolic = Column(Integer, nullable=True)
    baseline_heart_rate = Column(Integer, nullable=True)
    baseline_temperature = Column(Numeric(4, 1), nullable=True)
    baseline_spo2 = Column(Integer, nullable=True)
    baseline_weight = Column(Numeric(5, 2), nullable=True)
    baseline_height = Column(Numeric(5, 2), nullable=True)
    vitals_updated_at = Column(DateTime(timezone=True), nullable=True)

    # Social
    smoking_status = Column(String(20), nullable=True)
    alcohol_use = Column(String(20), nullable=True)
    occupation = Column(String(100), nullable=True)

    # Metadata
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    # Relationships
    user = relationship("User", back_populates="patient_profile", foreign_keys=[user_id])
    clinician = relationship("User", back_populates="patients", foreign_keys=[clinician_id])
    episodes = relationship("Episode", back_populates="patient", cascade="all, delete-orphan", order_by="desc(Episode.started_at)")
    prescriptions = relationship("Prescription", back_populates="patient", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_patients_clinician_active", "clinician_id", "is_active"),
        Index("ix_patients_dob_sex", "date_of_birth", "sex"),
        Index("ix_patients_name_search", "first_name", "last_name"),
    )

    @property
    def age(self) -> int:
        from datetime import date
        today = date.today()
        return today.year - self.date_of_birth.year - ((today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day))

    @property
    def bmi(self) -> float | None:
        if self.baseline_weight and self.baseline_height:
            h_m = float(self.baseline_height) / 100
            return round(float(self.baseline_weight) / (h_m * h_m), 1)
        return None

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"

    @property
    def active_conditions(self) -> list[dict]:
        return [c for c in self.chronic_conditions if c.get("active", True)]

    @property
    def active_medications(self) -> list[dict]:
        return [m for m in self.current_medications if m.get("active", True)]


# =====================================================================
# VITAL SIGNS (Module 3.1 exercise)
# =====================================================================

class VitalSource(str, enum.Enum):
    MANUAL = "manual"
    DEVICE = "device"
    IMPORT = "import"

class VitalSigns(Base):
    __tablename__ = "vital_signs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    measured_at = Column(DateTime(timezone=True), nullable=False, index=True)

    bp_systolic = Column(Integer, nullable=True)
    bp_diastolic = Column(Integer, nullable=True)
    heart_rate = Column(Integer, nullable=True)
    temperature = Column(Numeric(4, 1), nullable=True)
    spo2 = Column(Integer, nullable=True)
    respiratory_rate = Column(Integer, nullable=True)
    weight = Column(Numeric(5, 2), nullable=True)
    height = Column(Numeric(5, 2), nullable=True)
    bmi = Column(Numeric(4, 1), nullable=True)

    source = Column(Enum(VitalSource), default=VitalSource.MANUAL, nullable=False)
    device_id = Column(String(100), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    patient = relationship("Patient", back_populates="vital_signs_history")

    __table_args__ = (
        Index("ix_vital_signs_patient_measured", "patient_id", "measured_at"),
        Index("ix_vital_signs_patient_source", "patient_id", "source"),
    )

    def __init__(self, **kwargs):
        if kwargs.get("weight") and kwargs.get("height"):
            h_m = float(kwargs["height"]) / 100
            bmi_val = round(float(kwargs["weight"]) / (h_m * h_m), 1)
            kwargs["bmi"] = bmi_val
        super().__init__(**kwargs)


# Add vital_signs_history relationship to Patient
Patient.vital_signs_history = relationship("VitalSigns", back_populates="patient", cascade="all, delete-orphan", order_by="desc(VitalSigns.measured_at)")


# =====================================================================
# MEDICATION MODEL (Module 3.2)
# =====================================================================

class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True, autoincrement=True)

    generic_name = Column(String(200), nullable=False, index=True)
    brand_names = Column(JSON, default=list, nullable=False)
    atc_code = Column(String(10), nullable=False, index=True)
    atc_levels = Column(JSON, default=dict, nullable=False)

    therapeutic_class = Column(String(100), nullable=False, index=True)
    pharmacological_class = Column(String(100), nullable=False)

    active_ingredients = Column(JSON, default=list, nullable=False)
    presentations = Column(JSON, default=list, nullable=False)

    standard_dosage = Column(JSON, default=dict, nullable=False)
    indications = Column(JSON, default=list, nullable=False)
    contraindications = Column(JSON, default=list, nullable=False)
    precautions = Column(JSON, default=list, nullable=False)

    pregnancy_category = Column(Enum(PregnancyCategory), default=PregnancyCategory.N, nullable=False)
    lactation_category = Column(Enum(LactationCategory), default=LactationCategory.L3, nullable=False)
    pregnancy_notes = Column(Text, nullable=True)
    lactation_notes = Column(Text, nullable=True)

    half_life_hours = Column(Numeric(6, 2), nullable=True)
    bioavailability = Column(String(50), nullable=True)
    protein_binding = Column(String(50), nullable=True)
    metabolism = Column(Text, nullable=True)
    excretion = Column(Text, nullable=True)

    monitoring_parameters = Column(JSON, default=list, nullable=False)

    status = Column(Enum(MedicationStatus), default=MedicationStatus.ACTIVE, nullable=False)
    is_controlled = Column(Boolean, default=False, nullable=False)
    controlled_schedule = Column(String(10), nullable=True)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    interactions_as_a = relationship("DrugInteraction", foreign_keys="DrugInteraction.medication_a_id", back_populates="medication_a")
    interactions_as_b = relationship("DrugInteraction", foreign_keys="DrugInteraction.medication_b_id", back_populates="medication_b")
    prescriptions = relationship("Prescription", back_populates="medication")

    __table_args__ = (
        Index("ix_medications_generic_active", "generic_name", "status"),
        Index("ix_medications_atc_class", "atc_code", "therapeutic_class"),
        UniqueConstraint("generic_name", "atc_code", name="uq_medication_generic_atc"),
    )


class DrugInteraction(Base):
    __tablename__ = "drug_interactions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    medication_a_id = Column(ForeignKey("medications.id", ondelete="CASCADE"), nullable=False, index=True)
    medication_b_id = Column(ForeignKey("medications.id", ondelete="CASCADE"), nullable=False, index=True)

    severity = Column(String(20), nullable=False, index=True)
    mechanism = Column(Text, nullable=False)
    clinical_effect = Column(Text, nullable=False)
    management = Column(Text, nullable=False)

    evidence_level = Column(String(20), nullable=True)
    references = Column(JSON, default=list, nullable=False)
    risk_factors = Column(JSON, default=list, nullable=False)

    is_bidirectional = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    medication_a = relationship("Medication", foreign_keys=[medication_a_id], back_populates="interactions_as_a")
    medication_b = relationship("Medication", foreign_keys=[medication_b_id], back_populates="interactions_as_b")

    __table_args__ = (
        UniqueConstraint("medication_a_id", "medication_b_id", name="uq_interaction_pair"),
        Index("ix_interactions_severity", "severity"),
    )


# =====================================================================
# PRESCRIPTION MODEL (Module 3.2 exercise)
# =====================================================================

class Prescription(Base):
    __tablename__ = "prescriptions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    clinician_id = Column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    medication_id = Column(ForeignKey("medications.id", ondelete="RESTRICT"), nullable=False, index=True)

    dose = Column(String(100), nullable=False)
    frequency = Column(String(50), nullable=False)
    route = Column(String(20), default="oral", nullable=False)
    duration_days = Column(Integer, nullable=True)
    quantity = Column(Integer, nullable=False)
    refills_allowed = Column(Integer, default=0, nullable=False)
    refills_used = Column(Integer, default=0, nullable=False)

    instructions = Column(Text, nullable=True)
    indication = Column(String(200), nullable=True)
    status = Column(Enum(PrescriptionStatus), default=PrescriptionStatus.ACTIVE, nullable=False)

    start_date = Column(Date, nullable=False, default=lambda: datetime.now(timezone.utc).date())
    end_date = Column(Date, nullable=True)
    last_dispensed_at = Column(DateTime(timezone=True), nullable=True)
    dispensed_quantity = Column(Integer, default=0, nullable=False)

    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    patient = relationship("Patient", back_populates="prescriptions")
    clinician = relationship("User", back_populates="prescriptions", foreign_keys=[clinician_id])
    medication = relationship("Medication", back_populates="prescriptions")

    __table_args__ = (
        Index("ix_prescriptions_patient_status", "patient_id", "status"),
        Index("ix_prescriptions_clinician_status", "clinician_id", "status"),
        Index("ix_prescriptions_patient_med_status", "patient_id", "medication_id", "status"),
    )

    def __init__(self, **kwargs):
        if "start_date" in kwargs and kwargs.get("duration_days"):
            start = kwargs["start_date"]
            if isinstance(start, str):
                start = datetime.fromisoformat(start).date()
            kwargs["end_date"] = start + timedelta(days=kwargs["duration_days"])
        super().__init__(**kwargs)

    @property
    def is_active(self) -> bool:
        return self.status == PrescriptionStatus.ACTIVE

    @property
    def days_remaining(self) -> int | None:
        from datetime import date
        if self.end_date:
            delta = self.end_date - date.today()
            return max(0, delta.days)
        return None

    @property
    def refills_remaining(self) -> int:
        return max(0, self.refills_allowed - self.refills_used)

    @property
    def daily_dose_count(self) -> int:
        freq = self.frequency.lower()
        if "/día" in freq or "por día" in freq or "daily" in freq:
            try:
                return int(freq.split("/")[0]) if freq.split("/")[0].isdigit() else 1
            except:
                return 1
        elif "cada" in freq and "h" in freq:
            try:
                hours = int(freq.split("cada")[1].split("h")[0].strip())
                return max(1, 24 // hours)
            except:
                return 1
        return 1


# =====================================================================
# EPISODE / CLINICAL NOTE / DOCUMENT (Modules 3.3, 3.4)
# =====================================================================

class Episode(Base):
    __tablename__ = "episodes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    patient_id = Column(ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    clinician_id = Column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)

    episode_type = Column(Enum(EpisodeType), default=EpisodeType.CONSULTATION, nullable=False)
    status = Column(Enum(EpisodeStatus), default=EpisodeStatus.OPEN, nullable=False)

    started_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    ended_at = Column(DateTime(timezone=True), nullable=True)
    scheduled_at = Column(DateTime(timezone=True), nullable=True)

    location = Column(String(200), nullable=True)
    department = Column(String(100), nullable=True)

    chief_complaint = Column(Text, nullable=False)
    reason_for_visit = Column(Text, nullable=True)

    # SOAP
    subjective = Column(JSON, default=dict, nullable=False)
    objective = Column(JSON, default=dict, nullable=False)
    assessment = Column(JSON, default=dict, nullable=False)
    plan = Column(JSON, default=dict, nullable=False)

    diagnoses = Column(JSON, default=list, nullable=False)
    procedures = Column(JSON, default=list, nullable=False)

    is_billable = Column(Boolean, default=True, nullable=False)
    requires_followup = Column(Boolean, default=False, nullable=False)
    followup_notes = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    patient = relationship("Patient", back_populates="episodes")
    clinician = relationship("User", back_populates="episodes")
    notes = relationship("ClinicalNote", back_populates="episode", cascade="all, delete-orphan", order_by="ClinicalNote.created_at")
    documents = relationship("ClinicalDocument", back_populates="episode", cascade="all, delete-orphan")

    __table_args__ = (
        Index("ix_episodes_patient_status", "patient_id", "status"),
        Index("ix_episodes_patient_type_date", "patient_id", "episode_type", "started_at"),
        Index("ix_episodes_clinician_date", "clinician_id", "started_at"),
        Index("ix_episodes_status_date", "status", "started_at"),
    )

    @property
    def is_open(self) -> bool:
        return self.status in [EpisodeStatus.OPEN, EpisodeStatus.IN_PROGRESS, EpisodeStatus.ON_HOLD]

    @property
    def primary_diagnosis(self) -> dict | None:
        for d in self.diagnoses:
            if d.get("type") == "primary":
                return d
        return self.diagnoses[0] if self.diagnoses else None


class ClinicalNote(Base):
    __tablename__ = "clinical_notes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    episode_id = Column(ForeignKey("episodes.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)

    note_type = Column(String(50), default="progress", nullable=False)
    title = Column(String(200), nullable=True)
    content = Column(Text, nullable=False)

    structured_data = Column(JSON, default=dict, nullable=False)

    is_signed = Column(Boolean, default=False, nullable=False)
    signed_at = Column(DateTime(timezone=True), nullable=True)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    episode = relationship("Episode", back_populates="notes")
    author = relationship("User", back_populates="clinical_notes")

    __table_args__ = (
        Index("ix_clinical_notes_episode_created", "episode_id", "created_at"),
    )


class ClinicalDocument(Base):
    __tablename__ = "clinical_documents"

    id = Column(Integer, primary_key=True, autoincrement=True)
    episode_id = Column(ForeignKey("episodes.id", ondelete="CASCADE"), nullable=False, index=True)
    uploaded_by = Column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True)

    filename = Column(String(255), nullable=False)
    original_filename = Column(String(255), nullable=False)
    mime_type = Column(String(100), nullable=False)
    size_bytes = Column(Integer, nullable=False)
    storage_path = Column(String(500), nullable=False)

    document_type = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    episode = relationship("Episode", back_populates="documents")
    uploader = relationship("User", back_populates="uploaded_documents")


# =====================================================================
# EXISTING MODELS (kept for compatibility)
# =====================================================================

class ChatConversation(Base):
    __tablename__ = "chat_conversations"
    id = Column(Integer, primary_key=True, autoincrement=True)
    titulo = Column(String(200), default="")
    modelo = Column(String(100), default="")
    mensajes = Column(Text, default="")
    creado_en = Column(BigInteger)
    actualizado_en = Column(BigInteger)


class TimerTurno(Base):
    __tablename__ = "timers"
    id = Column(Integer, primary_key=True, autoincrement=True)
    turno_id = Column(String, nullable=True)
    centro = Column(String, default="")
    entrada = Column(BigInteger)
    salida = Column(BigInteger, nullable=True)
    tarifa = Column(Float, default=0.0)
    activo = Column(Boolean, default=True)


class NotaTraspaso(Base):
    __tablename__ = "notas_traspaso"
    id = Column(Integer, primary_key=True, autoincrement=True)
    paciente = Column(String, nullable=False)
    diagnostico = Column(String, default="")
    resumen = Column(Text, default="")
    signos_vitales = Column(String, default="")
    actualizado = Column(BigInteger)
    completada = Column(Boolean, default=False)
    prioridad = Column(String, default="baja")


class PlanPAE(Base):
    __tablename__ = "planes_pae"
    id = Column(Integer, primary_key=True, autoincrement=True)
    paciente = Column(String, nullable=False)
    valoracion = Column(Text, default="")
    diagnostico_nanda = Column(String, default="")
    objetivos_noc = Column(String, default="")
    intervenciones_nic = Column(Text, default="")
    evaluacion = Column(Text, default="")
    timestamp = Column(BigInteger)


class Turno(Base):
    __tablename__ = "turnos"
    id = Column(Integer, primary_key=True, autoincrement=True)
    turno_id = Column(String(100), unique=True, nullable=False, index=True)
    centro = Column(String(200), default="")
    especialidad = Column(String(200), default="")
    tarifa = Column(Float, default=0.0)
    horas = Column(Float, default=0.0)
    estado = Column(String(50), default="DISPONIBLE")
    creado_en = Column(BigInteger)


class Credencial(Base):
    __tablename__ = "credenciales"
    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(200), nullable=False)
    emisor = Column(String(200), default="")
    numero = Column(String(100), default="")
    fecha_expiracion = Column(String(20), default="")
    activa = Column(Boolean, default=True)
    creado_en = Column(BigInteger)


class DrugReference(Base):
    __tablename__ = "drug_references"
    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre_generico = Column(String(200), nullable=False, unique=True)
    categoria = Column(String(200), default="")
    indicacion = Column(Text, default="")
    dosis_adulto = Column(String(300), default="")
    dosis_pediatrica = Column(String(300), default="")
    via = Column(String(200), default="")
    precauciones = Column(Text, default="")
    alerta = Column(Text, default="")
    presentacion = Column(Text, default="")
    contraindicaciones = Column(Text, default="")
    interacciones = Column(Text, default="")
    efectos_adversos = Column(Text, default="")
    embarazo_lactancia = Column(Text, default="")
    mecanismo_accion = Column(Text, default="")