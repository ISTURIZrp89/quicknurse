import { useState } from 'react'
import { usePatients, usePatientsActions } from '../../hooks'

export const ShiftsPage = () => {
  const { shifts, patients } = usePatients()
  const { addShift } = usePatientsActions()
  const [showAddModal, setShowAddModal] = useState(false)
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    startTime: '07:00',
    endTime: '15:00',
    patients: [] as string[],
    notes: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const newShift = {
      id: Date.now().toString(),
      ...formData,
      completed: false,
    }
    addShift(newShift)
    setFormData({ date: new Date().toISOString().split('T')[0], startTime: '07:00', endTime: '15:00', patients: [], notes: '' })
    setShowAddModal(false)
  }

  return (
    <div className="min-h-screen bg-surface-bg">
      <header className="sticky top-0 z-10 bg-surface-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">Turnos</h1>
          <button onClick={() => setShowAddModal(true)} className="p-2 rounded-lg bg-clinicalBlue text-white hover:bg-clinicalBlue/90">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
          </button>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        {shifts.length === 0 ? (
          <div className="text-center py-16">
            <svg className="w-16 h-16 mx-auto mb-4 text-text-disabled" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <h3 className="text-lg font-medium text-text-primary mt-4">Sin turnos registrados</h3>
            <p className="text-text-secondary mt-2">Agrega tu primer turno</p>
            <button onClick={() => setShowAddModal(true)} className="btn-primary mt-4">Agregar turno</button>
          </div>
        ) : (
          <div className="space-y-3">
            {shifts.map((shift) => (
              <div key={shift.id} className="bg-surface-card border border-border-default rounded-xl p-4">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-clinicalBlue/10 flex items-center justify-center">
                      <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                        <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <div>
                      <h3 className="font-medium text-text-primary">{new Date(shift.date).toLocaleDateString('es-ES', { weekday: 'long', day: 'numeric', month: 'long' })}</h3>
                      <p className="text-xs text-text-secondary">{shift.startTime} - {shift.endTime}</p>
                    </div>
                  </div>
                  <span className={`badge ${shift.completed ? 'badge-success' : 'badge-warning'}`}>
                    {shift.completed ? 'Completado' : 'Pendiente'}
                  </span>
                </div>

                {shift.patients.length > 0 && (
                  <div className="flex flex-wrap gap-2 mb-3">
                    {shift.patients.map((pid) => {
                      const patient = patients.find(p => p.id === pid)
                      return patient ? (
                        <span key={pid} className="badge badge-info">{patient.name}</span>
                      ) : null
                    })}
                  </div>
                )}

                {shift.notes && (
                  <p className="text-sm text-text-secondary">{shift.notes}</p>
                )}
              </div>
            ))}
          </div>
        )}

        {showAddModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
            <div className="bg-surface-card border border-border-default rounded-xl p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
              <h3 className="text-lg font-bold text-text-primary mb-4">Nuevo turno</h3>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="label-clinical">Fecha</label>
                  <input type="date" value={formData.date} onChange={(e) => setFormData(prev => ({ ...prev, date: e.target.value }))} className="input-clinical" required />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="label-clinical">Inicio</label>
                    <input type="time" value={formData.startTime} onChange={(e) => setFormData(prev => ({ ...prev, startTime: e.target.value }))} className="input-clinical" />
                  </div>
                  <div>
                    <label className="label-clinical">Fin</label>
                    <input type="time" value={formData.endTime} onChange={(e) => setFormData(prev => ({ ...prev, endTime: e.target.value }))} className="input-clinical" />
                  </div>
                </div>
                <div>
                  <label className="label-clinical">Pacientes</label>
                  <div className="space-y-2 max-h-40 overflow-y-auto">
                    {patients.map((patient) => (
                      <label key={patient.id} className="flex items-center gap-3 p-2 rounded-lg hover:bg-surface-cardHover cursor-pointer">
                        <input
                          type="checkbox"
                          checked={formData.patients.includes(patient.id)}
                          onChange={(e) => setFormData(prev => ({
                            ...prev,
                            patients: e.target.checked
                              ? [...prev.patients, patient.id]
                              : prev.patients.filter(id => id !== patient.id)
                          }))}
                          className="w-4 h-4 text-clinicalBlue rounded border-border-default focus:ring-clinicalBlue"
                        />
                        <span className="text-sm text-text-primary">{patient.name}</span>
                      </label>
                    ))}
                  </div>
                </div>
                <div>
                  <label className="label-clinical">Notas</label>
                  <textarea value={formData.notes} onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))} rows={3} className="input-clinical" />
                </div>
                <div className="flex gap-3 pt-2">
                  <button type="button" onClick={() => setShowAddModal(false)} className="flex-1 btn-secondary">Cancelar</button>
                  <button type="submit" className="flex-1 btn-primary">Guardar turno</button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default ShiftsPage