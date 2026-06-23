from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date


# =====================================================================
# PATIENT SCHEMAS
# =====================================================================

class PatientCreate(BaseModel):
    user_id: int
    clinician_id: Optional[int] = None
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)
    date_of_birth: date
    sex: str
    blood_type: str = "unknown"
    phone: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    allergies: list = []
    drug_allergies: list = []
    chronic_conditions: list = []
    current_medications: list = []
    surgical_history: list = []
    family_history: list = []
    immunizations: list = []
    baseline_bp_systolic: Optional[int] = None
    baseline_bp_diastolic: Optional[int] = None
    baseline_heart_rate: Optional[int] = None
    baseline_temperature: Optional[float] = None
    baseline_spo2: Optional[int] = None
    baseline_weight: Optional[float] = None
    baseline_height: Optional[float] = None
    smoking_status: Optional[str] = None
    alcohol_use: Optional[str] = None
    occupation: Optional[str] = None


class PatientUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    clinician_id: Optional[int] = None
    phone: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    allergies: Optional[list] = None
    drug_allergies: Optional[list] = None
    chronic_conditions: Optional[list] = None
    current_medications: Optional[list] = None
    surgical_history: Optional[list] = None
    family_history: Optional[list] = None
    immunizations: Optional[list] = None
    baseline_bp_systolic: Optional[int] = None
    baseline_bp_diastolic: Optional[int] = None
    baseline_heart_rate: Optional[int] = None
    baseline_temperature: Optional[float] = None
    baseline_spo2: Optional[int] = None
    baseline_weight: Optional[float] = None
    baseline_height: Optional[float] = None
    smoking_status: Optional[str] = None
    alcohol_use: Optional[str] = None
    occupation: Optional[str] = None
    is_active: Optional[bool] = None


class PatientResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    full_name: str
    age: int
    date_of_birth: date
    sex: str
    blood_type: str
    phone: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    allergies: list = []
    drug_allergies: list = []
    chronic_conditions: list = []
    current_medications: list = []
    surgical_history: list = []
    family_history: list = []
    immunizations: list = []
    baseline_bp_systolic: Optional[int] = None
    baseline_bp_diastolic: Optional[int] = None
    baseline_heart_rate: Optional[int] = None
    baseline_temperature: Optional[float] = None
    baseline_spo2: Optional[int] = None
    baseline_weight: Optional[float] = None
    baseline_height: Optional[float] = None
    bmi: Optional[float] = None
    vitals_updated_at: Optional[datetime] = None
    smoking_status: Optional[str] = None
    alcohol_use: Optional[str] = None
    occupation: Optional[str] = None
    is_active: bool = True
    created_at: datetime
    updated_at: datetime


class PatientListResponse(BaseModel):
    id: int
    full_name: str
    age: int
    is_active: bool
    clinician_id: Optional[int] = None
    created_at: datetime


class PatientSearchResponse(BaseModel):
    id: int
    full_name: str
    age: int


# =====================================================================
# VITAL SIGNS SCHEMAS
# =====================================================================

class VitalSignsCreate(BaseModel):
    patient_id: Optional[int] = None
    measured_at: Optional[datetime] = None
    bp_systolic: Optional[int] = None
    bp_diastolic: Optional[int] = None
    heart_rate: Optional[int] = None
    temperature: Optional[float] = None
    spo2: Optional[int] = None
    respiratory_rate: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    source: str = "manual"
    device_id: Optional[str] = None
    notes: Optional[str] = None


class VitalSignsResponse(BaseModel):
    id: int
    measured_at: datetime
    bp_systolic: Optional[int] = None
    bp_diastolic: Optional[int] = None
    heart_rate: Optional[int] = None
    temperature: Optional[float] = None
    spo2: Optional[int] = None
    respiratory_rate: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    bmi: Optional[float] = None
    source: str


class VitalSignsTrendResponse(BaseModel):
    parameter: str
    data: list
    days: int


# =====================================================================
# MEDICATION SCHEMAS
# =====================================================================

class MedicationSearchResponse(BaseModel):
    id: int
    generic_name: str
    brand_names: list = []
    atc_code: str
    therapeutic_class: str
    pharmacological_class: str
    pregnancy_category: str
    lactation_category: str
    is_controlled: bool


class InteractionMedicationRef(BaseModel):
    id: int
    name: str


class DrugInteractionResponse(BaseModel):
    id: int
    severity: str
    mechanism: str
    clinical_effect: str
    management: str
    evidence_level: Optional[str] = None
    references: list = []
    risk_factors: list = []
    is_bidirectional: bool
    other_medication: InteractionMedicationRef


class MedicationDetailResponse(BaseModel):
    id: int
    generic_name: str
    brand_names: list = []
    atc_code: str
    atc_levels: dict = {}
    therapeutic_class: str
    pharmacological_class: str
    active_ingredients: list = []
    presentations: list = []
    standard_dosage: dict = {}
    indications: list = []
    contraindications: list = []
    precautions: list = []
    pregnancy_category: str
    lactation_category: str
    half_life_hours: Optional[float] = None
    bioavailability: Optional[str] = None
    protein_binding: Optional[str] = None
    metabolism: Optional[str] = None
    excretion: Optional[str] = None
    monitoring_parameters: list = []
    status: str
    is_controlled: bool
    controlled_schedule: Optional[str] = None
    interactions: List[DrugInteractionResponse] = []


class InteractionCheckRequest(BaseModel):
    medication_ids: List[int]
    patient_factors: Optional[dict] = None


class DosageCalculateRequest(BaseModel):
    medication_id: int
    patient_data: dict = {}


# =====================================================================
# PRESCRIPTION SCHEMAS
# =====================================================================

class PrescriptionCreate(BaseModel):
    medication_id: int
    dose: str = Field(..., min_length=1)
    frequency: str = Field(..., min_length=1)
    route: str = "oral"
    duration_days: Optional[int] = None
    quantity: int = Field(..., gt=0)
    refills_allowed: int = 0
    instructions: Optional[str] = None
    indication: Optional[str] = None
    start_date: Optional[date] = None
    notes: Optional[str] = None


class PrescriptionUpdate(BaseModel):
    dose: Optional[str] = None
    frequency: Optional[str] = None
    route: Optional[str] = None
    duration_days: Optional[int] = None
    quantity: Optional[int] = None
    refills_allowed: Optional[int] = None
    instructions: Optional[str] = None
    indication: Optional[str] = None
    status: Optional[str] = None
    notes: Optional[str] = None


class PrescriptionMedicationRef(BaseModel):
    id: int
    generic_name: str
    therapeutic_class: str


class PrescriptionResponse(BaseModel):
    id: int
    medication: PrescriptionMedicationRef
    dose: str
    frequency: str
    route: str
    duration_days: Optional[int] = None
    quantity: int
    refills_allowed: int
    refills_used: int
    refills_remaining: int
    instructions: Optional[str] = None
    indication: Optional[str] = None
    status: str
    start_date: date
    end_date: Optional[date] = None
    days_remaining: Optional[int] = None
    last_dispensed_at: Optional[datetime] = None
    dispensed_quantity: int
    clinician_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime


class PrescriptionListResponse(BaseModel):
    id: int
    medication_name: str
    dose: str
    frequency: str
    status: str
    start_date: date
    end_date: Optional[date] = None
    days_remaining: Optional[int] = None
    refills_remaining: int


class PrescriptionDispenseResponse(BaseModel):
    id: int
    dispensed_quantity: int
    refills_used: int
    refills_remaining: int
    status: str
    last_dispensed_at: Optional[datetime] = None


# =====================================================================
# EPISODE SCHEMAS
# =====================================================================

class EpisodeCreate(BaseModel):
    episode_type: str = "consultation"
    started_at: Optional[datetime] = None
    scheduled_at: Optional[datetime] = None
    location: Optional[str] = None
    department: Optional[str] = None
    chief_complaint: str = Field(..., min_length=1)
    reason_for_visit: Optional[str] = None
    subjective: dict = {}
    objective: dict = {}
    assessment: dict = {}
    plan: dict = {}
    diagnoses: list = []
    procedures: list = []
    is_billable: bool = True
    requires_followup: bool = False
    followup_notes: Optional[str] = None


class EpisodeUpdate(BaseModel):
    episode_type: Optional[str] = None
    location: Optional[str] = None
    department: Optional[str] = None
    chief_complaint: Optional[str] = None
    reason_for_visit: Optional[str] = None
    subjective: Optional[dict] = None
    objective: Optional[dict] = None
    assessment: Optional[dict] = None
    plan: Optional[dict] = None
    diagnoses: Optional[list] = None
    procedures: Optional[list] = None
    is_billable: Optional[bool] = None
    requires_followup: Optional[bool] = None
    followup_notes: Optional[str] = None


class EpisodeListResponse(BaseModel):
    id: int
    episode_type: str
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    chief_complaint: str
    is_open: bool


class EpisodeResponse(BaseModel):
    id: int
    patient_id: int
    clinician_id: Optional[int] = None
    episode_type: str
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    scheduled_at: Optional[datetime] = None
    location: Optional[str] = None
    department: Optional[str] = None
    chief_complaint: str
    reason_for_visit: Optional[str] = None
    subjective: dict = {}
    objective: dict = {}
    assessment: dict = {}
    plan: dict = {}
    diagnoses: list = []
    procedures: list = []
    is_billable: bool
    requires_followup: bool
    followup_notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    is_open: bool


# =====================================================================
# CLINICAL NOTE SCHEMAS
# =====================================================================

class ClinicalNoteCreate(BaseModel):
    note_type: str = "progress"
    title: Optional[str] = None
    content: str = Field(..., min_length=1)
    structured_data: dict = {}


class ClinicalNoteResponse(BaseModel):
    id: int
    note_type: str
    title: Optional[str] = None
    content: str
    structured_data: dict = {}
    is_signed: bool
    signed_at: Optional[datetime] = None
    author_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime


# =====================================================================
# CLINICAL DOCUMENT SCHEMAS
# =====================================================================

class ClinicalDocumentCreate(BaseModel):
    episode_id: int
    filename: str = Field(..., min_length=1)
    original_filename: str = Field(..., min_length=1)
    mime_type: str = Field(..., min_length=1)
    size_bytes: int = Field(..., ge=0)
    storage_path: str = Field(..., min_length=1)
    document_type: Optional[str] = None
    description: Optional[str] = None


class ClinicalDocumentResponse(BaseModel):
    id: int
    filename: str
    original_filename: str
    mime_type: str
    size_bytes: int
    document_type: Optional[str] = None
    description: Optional[str] = None
    created_at: datetime


# =====================================================================
# TIMELINE SCHEMAS
# =====================================================================

class TimelineEntry(BaseModel):
    type: str
    id: int
    timestamp: datetime
    title: str
    description: str
