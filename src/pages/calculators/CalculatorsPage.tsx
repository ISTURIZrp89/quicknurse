import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useCalculatorsActions } from '../../hooks'

export const CalculatorsPage = () => {
  const { resetCalculator } = useCalculatorsActions()
  const [searchQuery, setSearchQuery] = useState('')

  const formulas = [
    { id: 'mgKgDose', name: 'Dosis mg/kg', description: 'Calcula dosis basada en peso corporal', category: 'Dosis', icon: 'pill' },
    { id: 'pediatricDose', name: 'Dosis Pediátrica', description: 'Dosis pediátrica ajustada por peso (Clark)', category: 'Pediátrico', icon: 'baby' },
    { id: 'mgToMl', name: 'Conversión mg a mL', description: 'Convierte miligramos a mililitros según concentración', category: 'Dosis', icon: 'droplet' },
    { id: 'maxDoseCheck', name: 'Verificación Dosis Máxima', description: 'Verifica si la dosis supera el máximo seguro', category: 'Dosis', icon: 'alert-triangle' },
    { id: 'dropsPerMin', name: 'Gotas por Minuto', description: 'Calcula velocidad de goteo en gotas/minuto', category: 'Infusión', icon: 'droplet' },
    { id: 'microdropsPerMin', name: 'Microgotas por Minuto', description: 'Calcula velocidad en microgotas/minuto', category: 'Infusión', icon: 'droplet' },
    { id: 'infusionMlPerH', name: 'Infusión mL/h', description: 'Calcula velocidad de infusión en mL/hora', category: 'Infusión', icon: 'droplet' },
    { id: 'fluidBalance', name: 'Balance Hídrico', description: 'Calcula balance entre ingresos y egresos', category: 'Balance Hídrico', icon: 'droplet' },
    { id: 'bodySurfaceArea', name: 'Superficie Corporal', description: 'Calcula superficie corporal (Mosteller)', category: 'Superficie Corporal', icon: 'user' },
    { id: 'sedationScore', name: 'Escala de Sedación (Ramsay)', description: 'Evalúa nivel de sedación (Ramsay)', category: 'Neurología', icon: 'brain' },
    { id: 'glasgowComa', name: 'Escala de Glasgow', description: 'Evalúa nivel de conciencia (3-15)', category: 'Escalas Clínicas', icon: 'brain' },
    { id: 'vasopressorDose', name: 'Dosis de Vasopresor', description: 'Calcula dosis de vasopresores en mcg/kg/min', category: 'Cardiología', icon: 'heart' },
    { id: 'qtc', name: 'QT Corregido (Bazett)', description: 'Intervalo QT corregido por frecuencia cardíaca', category: 'Cardiología', icon: 'heart' },
    { id: 'chadsVasc', name: 'CHA₂DS₂-VASc', description: 'Riesgo de ACV en fibrilación auricular', category: 'Cardiología', icon: 'heart' },
    { id: 'anionGap', name: 'Anión GAP', description: 'Brecha aniónica para diagnóstico metabólico', category: 'Nefrología', icon: 'flask' },
    { id: 'apacheScore', name: 'APACHE II (simplificado)', description: 'Gravedad en UCI (simplificado)', category: 'UCI', icon: 'activity' },
    { id: 'meldScore', name: 'MELD Score', description: 'Riesgo de mortalidad en hepatopatía', category: 'Hepatología', icon: 'heart' },
    { id: 'wellsCriteria', name: 'Criterios de Wells', description: 'Probabilidad de TEP/TVP', category: 'Neumología', icon: 'lungs' },
    { id: 'curb65', name: 'CURB-65', description: 'Gravedad de neumonía adquirida', category: 'Neumología', icon: 'lungs' },
  ]

  const filteredFormulas = formulas.filter(f => 
    f.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
    f.category.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const groupedFormulas = filteredFormulas.reduce((acc, formula) => {
    if (!acc[formula.category]) acc[formula.category] = []
    acc[formula.category].push(formula)
    return acc
  }, {} as Record<string, typeof formulas>)

  return (
    <div className="min-h-screen bg-deepBlack">
      <header className="sticky top-0 z-10 bg-deepBlack/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">Calculadoras Clínicas</h1>
          <button className="p-2 rounded-lg bg-dark-card hover:bg-dark-cardHover transition-colors" onClick={resetCalculator}>
            <svg className="w-6 h-6 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.348 0l1.086 3.663a3.002 3.002 0 002.804-.035l3.491-.059a.75.75 0 011.11.33l1.335 2.948a.75.75 0 01-.136 1.086l-3.1 2.265a.75.75 0 01-.672 0l-3.104 2.264a.75.75 0 01-1.121-.176l-1.33-2.95a.75.75 0 00-.21-.83l1.092-3.663a3.02 3.02 0 00-.177-1.569l-1.42.51z" />
            </svg>
          </button>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        <div className="mb-6">
          <div className="relative">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Buscar calculadora..."
              className="w-full px-4 py-3 pr-10 bg-dark-input border border-border-default rounded-lg text-text-primary placeholder:text-text-disabled focus:outline-none focus:ring-2 focus:ring-clinicalBlue"
            />
            <svg className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-text-disabled" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>

          {Object.keys(groupedFormulas).length === 0 ? (
            <div className="text-center py-12 text-text-disabled">
              <svg className="w-16 h-16 mx-auto mb-4 text-text-disabled" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <p className="text-text-secondary">Sin resultados para &quot;{searchQuery}&quot;</p>
            </div>
          ) : (
            <div className="space-y-6">
              {Object.entries(groupedFormulas).map(([category, formulas]) => (
                <div key={category} className="mb-6">
                  <div className="flex items-center gap-2 mb-3 px-1">
                    <svg className="w-4 h-4 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414c.39.39.39 1.023 0 1.414l-4 4a2 2 0 01-2.828 0L5 13.172V7a2 2 0 012-2h1.586" />
                    </svg>
                    <span className="text-xs font-bold text-clinicalBlue uppercase tracking-wider">{category}</span>
                  </div>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                    {formulas.map((formula) => (
                      <Link
                        key={formula.id}
                        to={`/calculators/${formula.id}`}
                        className="group block"
                      >
                        <div className="bg-dark-card border border-border-default rounded-xl p-4 hover:border-clinicalBlue/50 hover:border-opacity-50 transition-colors duration-200">
                          <div className="flex items-start gap-3 mb-2">
                            <div className="w-10 h-10 rounded-lg bg-clinicalBlue/10 flex items-center justify-center flex-shrink-0">
                              <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5V6m0 12v3m0-17.5a6 6 0 00-12 0v3a6 6 0 007.24 5.34M12 3a6 6 0 00-6 6v3a6 6 0 007.24 5.34m0 0a8 8 0 11-16 0" />
                              </svg>
                            </div>
                            <div className="flex-1 min-w-0">
                              <h3 className="font-medium text-text-primary text-sm truncate">{formula.name}</h3>
                              <p className="text-xs text-text-secondary mt-0.5 truncate">{formula.description}</p>
                            </div>
                          </div>
                        </div>
                      </Link>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default CalculatorsPage