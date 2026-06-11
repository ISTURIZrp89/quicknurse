import { useState } from 'react'
import { useParams } from 'react-router-dom'
import { useCalculators, useCalculatorsActions } from '../../hooks'

interface FormulaParam {
  name: string
  label: string
  unit: string
  value: number
  min: number
  max: number
  required: boolean
}

const calculatorParams: Record<string, FormulaParam[]> = {
  mgKgDose: [
    { name: 'weight', label: 'Peso', unit: 'kg', value: 70, min: 0.5, max: 300, required: true },
    { name: 'dosePerKg', label: 'Dosis por kg', unit: 'mg/kg', value: 10, min: 0.01, max: 1000, required: true },
  ],
  dropsPerMin: [
    { name: 'volume', label: 'Volumen', unit: 'mL', value: 500, min: 1, max: 5000, required: true },
    { name: 'time', label: 'Tiempo', unit: 'min', value: 60, min: 1, max: 1440, required: true },
    { name: 'dropFactor', label: 'Factor de gotas', unit: 'gtt/mL', value: 20, min: 10, max: 60, required: true },
  ],
}

export const CalculatorDetailPage = () => {
  const { type } = useParams<{ type: string }>()
  const { result, isLoading, error } = useCalculators()
  const { setResult, setLoading, setError, resetCalculator } = useCalculatorsActions()
  const [localParams, setLocalParams] = useState<Record<string, any>>({})

  const params = calculatorParams[type || ''] || []

  const calculate = () => {
    setLoading(true)
    setError(null)
    let resultValue = 0
    let unit = ''
    let description = ''
    let isWarning = false
    let isCritical = false

    if (type === 'mgKgDose') {
      const weight = localParams.weight || 70
      const dosePerKg = localParams.dosePerKg || 10
      resultValue = weight * dosePerKg
      unit = 'mg'
      description = `Dosis total calculada para paciente de ${weight} kg a ${dosePerKg} mg/kg`
      isWarning = resultValue > 1000
    } else if (type === 'dropsPerMin') {
      const volume = localParams.volume || 500
      const time = localParams.time || 60
      const dropFactor = localParams.dropFactor || 20
      resultValue = (volume * dropFactor) / time
      unit = 'gtt/min'
      description = `Velocidad de goteo: ${volume} mL en ${time} min con factor ${dropFactor} gtt/mL`
      isWarning = resultValue > 60 || resultValue < 10
    }

    setResult({
      result: Math.round(resultValue * 100) / 100,
      unit,
      label: 'Resultado',
      description,
      isWarning,
      isCritical,
      details: localParams,
    })
  }

  return (
    <div className="min-h-screen bg-deepBlack">
      <header className="sticky top-0 z-10 bg-deepBlack/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">Calculadora</h1>
          <button className="p-2 rounded-lg bg-dark-card hover:bg-dark-cardHover transition-colors" onClick={resetCalculator}>
            <svg className="w-5 h-5 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        <div className="bg-dark-card border border-border-default rounded-xl p-4 mb-6">
          <h2 className="text-lg font-semibold text-text-primary mb-2">{type === 'mgKgDose' ? 'Dosis mg/kg' : type === 'dropsPerMin' ? 'Gotas por Minuto' : 'Calculadora'}</h2>
          <p className="text-sm text-text-secondary">{type === 'mgKgDose' ? 'Calcula dosis basada en peso corporal' : type === 'dropsPerMin' ? 'Calcula velocidad de goteo en gotas/minuto' : 'Calculadora clínica'}</p>
        </div>

        {params.map((param) => (
          <div key={param.name} className="mb-4">
            <label className="label-clinical">{param.label} ({param.unit})</label>
            <input
              type="number"
              value={localParams[param.name] || param.value}
              onChange={(e) => setLocalParams(prev => ({ ...prev, [param.name]: parseFloat(e.target.value) }))}
              min={param.min}
              max={param.max}
              step="any"
              className="input-clinical"
              required={param.required}
            />
          </div>
        ))}

        <div className="space-y-3 pt-4">
          <button
            onClick={calculate}
            disabled={isLoading}
            className="w-full btn-primary"
          >
            {isLoading ? 'Calculando...' : 'Calcular'}
          </button>
          <button
            onClick={resetCalculator}
            className="w-full btn-secondary"
          >
            Limpiar
          </button>
        </div>

        {error && (
          <div className="mt-4 p-3 bg-alert-red/10 border border-alert-red/30 rounded-lg text-sm text-alert-red">
            {error}
          </div>
        )}

        {result && (
          <div className="mt-6 p-4 bg-clinicalBlue/10 border border-clinicalBlue/20 rounded-xl animate-slide-up">
            <div className="flex items-baseline justify-between mb-2">
              <span className="text-xs font-bold text-clinicalBlue uppercase tracking-wider">{result.label}</span>
              {result.isCritical && <span className="badge-danger">CRÍTICO</span>}
              {result.isWarning && !result.isCritical && <span className="badge-warning">PRECAUCIÓN</span>}
            </div>
            <div className="flex items-baseline gap-2 mb-2">
              <span className="text-4xl font-bold text-clinicalBlue">{result.result}</span>
              <span className="text-lg text-text-secondary self-end mb-1">{result.unit}</span>
            </div>
            <p className="text-sm text-text-secondary">{result.description}</p>
          </div>
        )}
      </div>
    </div>
  )
}

export default CalculatorDetailPage