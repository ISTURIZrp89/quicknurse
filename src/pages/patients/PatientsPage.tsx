import { useState } from 'react'
import { Link } from 'react-router-dom'
import { usePatients, usePatientsActions } from '../../hooks'

interface FormData {
  name: string
  age: string
  weight: string
  gender: 'male' | 'female' | 'other'
  diagnosis: string
}

export const PatientsPage = () => {
  const { patients } = usePatients()
  const { addPatient } = usePatientsActions()
  const [showAddModal, setShowAddModal] = useState(false)
  const [formData, setFormData] = useState<FormData>({
    name: '',
    age: '',
    weight: '',
    gender: 'male',
    diagnosis: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const newPatient = {
      id: Date.now().toString(),
      name: formData.name,
      age: parseInt(formData.age),
      weight: parseFloat(formData.weight),
      gender: formData.gender,
      diagnosis: [formData.diagnosis],
      medications: [],
      allergies: [],
      vitalSigns: {},
      notes: '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }
    addPatient(newPatient)
    setFormData({ name: '', age: '', weight: '', gender: 'male', diagnosis: '' })
    setShowAddModal(false)
  }

  return (
    <div className="min-h-screen bg-surface-bg">
      <header className="sticky top-0 z-10 bg-surface-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">Pacientes</h1>
          <button
            onClick={() => setShowAddModal(true)}
            className="p-2 rounded-lg bg-clinicalBlue text-white hover:bg-clinicalBlue/90"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
          </button>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        {patients.length === 0 ? (
          <div className="text-center py-16">
            <svg className="w-16 h-16 mx-auto mb-4 text-text-disabled" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1a2 2 0 00-2 2H3a2 2 0 00-2 2v1a2 2 0 002 2h18a2 2 0 002-2v-1a2 2 0 00-2-2h-2M12 4.154a4 4 0 110 5.292" />
            </svg>
            <h3 className="text-lg font-medium text-text-primary mt-4">Sin pacientes</h3>
            <p className="text-text-secondary mt-2">Agrega tu primer paciente para empezar</p>
            <button
              onClick={() => setShowAddModal(true)}
              className="mt-4 btn-primary"
            >
              Agregar paciente
            </button>
          </div>
        ) : (
          <div className="space-y-3">
            {patients.map((patient) => (
              <Link
                key={patient.id}
                to={`/patients/${patient.id}`}
                className="block bg-surface-card border border-border-default rounded-xl p-4 hover:border-clinicalBlue/50 transition-colors"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-clinicalBlue/10 flex items-center justify-center">
                      <svg className="w-6 h-6 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h10a7 7 0 00-7-7z" />
                      </svg>
                    </div>
                    <div>
                      <h3 className="font-medium text-text-primary">{patient.name}</h3>
                      <p className="text-xs text-text-secondary">{patient.age} años • {patient.weight} kg</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium text-clinicalBlue">{patient.diagnosis[0] || 'Sin diagnóstico'}</p>
                    <p className="text-xs text-text-secondary">Actualizado: {new Date(patient.updatedAt).toLocaleDateString()}</p>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}

        {showAddModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
            <div className="bg-surface-card border border-border-default rounded-xl p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
              <h3 className="text-lg font-bold text-text-primary mb-4">Nuevo paciente</h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="label-clinical">Nombre</label>
                  <input type="text" value={formData.name} onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))} className="input-clinical" required />
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="label-clinical">Edad</label>
                    <input type="number" value={formData.age} onChange={(e) => setFormData(prev => ({ ...prev, age: e.target.value }))} className="input-clinical" min="0" max="150" required />
                  </div>
                  <div>
                    <label className="label-clinical">Peso (kg)</label>
                    <input type="number" value={formData.weight} onChange={(e) => setFormData(prev => ({ ...prev, weight: e.target.value }))} className="input-clinical" step="0.1" min="0.5" max="300" required />
                  </div>
                  <div>
                    <label className="label-clinical">Género</label>
                    <select value={formData.gender} onChange={(e) => setFormData(prev => ({ ...prev, gender: e.target.value as 'male' | 'female' | 'other' }))} className="input-clinical">
                      <option value="male">Masculino</option>
                      <option value="female">Femenino</option>
                      <option value="other">Otro</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label className="label-clinical">Diagnóstico inicial</label>
                  <input type="text" value={formData.diagnosis} onChange={(e) => setFormData(prev => ({ ...prev, diagnosis: e.target.value }))} className="input-clinical" placeholder="Ej: Hipertensión arterial" />
                </div>
                <div className="flex gap-3 pt-2">
                  <button type="button" onClick={() => setShowAddModal(false)} className="flex-1 btn-secondary">Cancelar</button>
                  <button type="submit" className="flex-1 btn-primary">Guardar paciente</button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default PatientsPage