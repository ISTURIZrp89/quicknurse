import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { usePatients, usePatientsActions } from '../../hooks'

export const PatientDetailPage = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { patients } = usePatients()
  const { deletePatient } = usePatientsActions()
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)

  const patient = patients.find(p => p.id === id)

  if (!patient) {
    return (
      <div className="min-h-screen bg-deepBlack flex items-center justify-center">
        <div className="text-center">
          <p className="text-text-secondary">Paciente no encontrado</p>
          <button onClick={() => navigate('/patients')} className="btn-primary mt-4">Volver</button>
        </div>
      </div>
    )
  }

  const vitalSignsEntries = Object.entries({
    'FC': patient.vitalSigns.heartRate,
    'PA': patient.vitalSigns.bloodPressure ? `${patient.vitalSigns.bloodPressure.systolic}/${patient.vitalSigns.bloodPressure.diastolic}` : null,
    'FR': patient.vitalSigns.respiratoryRate,
    'Temp': patient.vitalSigns.temperature ? `${patient.vitalSigns.temperature}°C` : null,
    'SpO₂': patient.vitalSigns.spo2 ? `${patient.vitalSigns.spo2}%` : null,
  }).filter(([_, v]) => v !== null)

  return (
    <div className="min-h-screen bg-deepBlack">
      <header className="sticky top-0 z-10 bg-deepBlack/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">{patient.name}</h1>
          <div className="flex items-center gap-2">
            <button className="p-2 rounded-lg bg-dark-card hover:bg-dark-cardHover transition-colors">
              <svg className="w-5 h-5 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
              </svg>
            </button>
            <button 
              onClick={() => setShowDeleteConfirm(true)}
              className="p-2 rounded-lg bg-alert-red/10 hover:bg-alert-red/20 transition-colors text-alert-red"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        <div className="space-y-4">
          <div className="bg-dark-card border border-border-default rounded-xl p-4">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-16 h-16 rounded-full bg-clinicalBlue/10 flex items-center justify-center">
                <svg className="w-8 h-8 text-clinicalBlue" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                </svg>
              </div>
              <div>
                <h2 className="text-xl font-bold text-text-primary">{patient.name}</h2>
                <p className="text-text-secondary">{patient.age} años • {patient.weight} kg • {patient.gender === 'male' ? 'Masculino' : patient.gender === 'female' ? 'Femenino' : 'Otro'}</p>
              </div>
            </div>
          </div>

          <div className="bg-dark-card border border-border-default rounded-xl p-4">
            <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-3">Diagnósticos</h3>
            <div className="flex flex-wrap gap-2">
              {patient.diagnosis.map((d, i) => (
                <span key={i} className="badge badge-info">{d}</span>
              ))}
              {patient.diagnosis.length === 0 && <span className="text-text-disabled text-sm">Sin diagnósticos registrados</span>}
            </div>
          </div>

          <div className="bg-dark-card border border-border-default rounded-xl p-4">
            <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-3">Medicamentos</h3>
            <div className="flex flex-wrap gap-2">
              {patient.medications.map((m, i) => (
                <span key={i} className="badge badge-success">{m}</span>
              ))}
              {patient.medications.length === 0 && <span className="text-text-disabled text-sm">Sin medicamentos registrados</span>}
            </div>
          </div>

          <div className="bg-dark-card border border-border-default rounded-xl p-4">
            <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-3">Alergias</h3>
            <div className="flex flex-wrap gap-2">
              {patient.allergies.map((a, i) => (
                <span key={i} className="badge badge-danger">{a}</span>
              ))}
              {patient.allergies.length === 0 && <span className="text-text-disabled text-sm">Sin alergias registradas</span>}
            </div>
          </div>

          <div className="bg-dark-card border border-border-default rounded-xl p-4">
            <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-3">Signos Vitales</h3>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {vitalSignsEntries.map(([label, value]) => (
                <div key={label} className="text-center p-3 bg-dark-input rounded-lg">
                  <p className="text-xs text-text-secondary uppercase tracking-wider">{label}</p>
                  <p className="text-xl font-bold text-text-primary">{value}</p>
                </div>
              ))}
              {vitalSignsEntries.length === 0 && (
                <div className="col-span-full text-center py-4 text-text-disabled">
                  Sin signos vitales registrados
                </div>
              )}
            </div>
          </div>

          {patient.notes && (
            <div className="bg-dark-card border border-border-default rounded-xl p-4">
              <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-3">Notas</h3>
              <p className="text-text-secondary">{patient.notes}</p>
            </div>
          )}
        </div>
      </div>

      {showDeleteConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="bg-dark-card border border-border-default rounded-xl p-6 w-full max-w-md mx-4">
            <h3 className="text-lg font-bold text-text-primary mb-2">Eliminar paciente</h3>
            <p className="text-text-secondary mb-6">¿Estás seguro de que quieres eliminar a {patient.name}? Esta acción no se puede deshacer.</p>
            <div className="flex gap-3">
              <button onClick={() => setShowDeleteConfirm(false)} className="flex-1 btn-secondary">Cancelar</button>
              <button onClick={() => { deletePatient(id!); navigate('/patients'); }} className="flex-1 btn-danger">Eliminar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default PatientDetailPage