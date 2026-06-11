import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface FormulaParameter {
  name: string
  label: string
  unit: string
  value: number | string | boolean
  min?: number
  max?: number
  required?: boolean
  options?: { value: string | number; label: string }[]
}

export interface CalculationResult {
  result: number
  unit: string
  label: string
  description: string
  isWarning: boolean
  isCritical: boolean
  details: Record<string, string | number>
  timestamp: string
}

export interface CalculatorState {
  currentFormula: string | null
  parameters: Record<string, FormulaParameter>
  result: CalculationResult | null
  isLoading: boolean
  error: string | null
  history: (CalculationResult & { formula: string; params: Record<string, number | string | boolean> })[]
}

const initialState: CalculatorState = {
  currentFormula: null,
  parameters: {},
  result: null,
  isLoading: false,
  error: null,
  history: [],
}

const calculatorsSlice = createSlice({
  name: 'calculators',
  initialState,
  reducers: {
    setFormula: (state, action: PayloadAction<string>) => {
      state.currentFormula = action.payload
      state.error = null
      state.result = null
    },
    updateParameter: (state, action: PayloadAction<{ name: string; value: number | string | boolean }>) => {
      if (state.parameters[action.payload.name]) {
        state.parameters[action.payload.name].value = action.payload.value
      }
    },
    setResult: (state, action: PayloadAction<{
      result: number
      unit: string
      label: string
      description: string
      isWarning: boolean
      isCritical: boolean
      details: Record<string, string | number>
    }>) => {
      const result = {
        ...action.payload,
        timestamp: new Date().toISOString(),
      }
      state.result = { ...result } as any
      state.isLoading = false
      state.error = null

      // Añadir al historial
      state.history.unshift({
        ...result,
        formula: state.currentFormula || '',
        params: Object.fromEntries(
          Object.entries(state.parameters).map(([k, v]) => [k, v.value])
        ),
        timestamp: new Date().toISOString(),
      } as any)
      if (state.history.length > 50) {
        state.history = state.history.slice(0, 50)
      }
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
      state.isLoading = false
    },
    resetCalculator: (state) => {
      state.currentFormula = null
      state.parameters = {}
      state.result = null
      state.error = null
    },
    clearHistory: (state) => {
      state.history = []
    },
    removeHistoryItem: (state, action: PayloadAction<number>) => {
      state.history.splice(action.payload, 1)
    },
  },
})

export const {
  setFormula,
  updateParameter,
  setResult,
  setLoading,
  setError,
  resetCalculator,
  clearHistory,
  removeHistoryItem,
} = calculatorsSlice.actions

export default calculatorsSlice.reducer