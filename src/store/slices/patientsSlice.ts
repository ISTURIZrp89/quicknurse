import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface Patient {
  id: string
  name: string
  age: number
  weight: number
  gender: 'male' | 'female' | 'other'
  diagnosis: string[]
  medications: string[]
  allergies: string[]
  vitalSigns: {
    heartRate?: number
    bloodPressure?: { systolic: number; diastolic: number }
    respiratoryRate?: number
    temperature?: number
    spo2?: number
  }
  notes: string
  createdAt: string
  updatedAt: string
}

export interface Shift {
  id: string
  date: string
  startTime: string
  endTime: string
  patients: string[] // patient IDs
  notes: string
  completed: boolean
}

export interface PatientsState {
  patients: Patient[]
  shifts: Shift[]
  currentPatient: Patient | null
  isLoading: boolean
  error: string | null
}

const initialState: PatientsState = {
  patients: [],
  shifts: [],
  currentPatient: null,
  isLoading: false,
  error: null,
}

const patientsSlice = createSlice({
  name: 'patients',
  initialState,
  reducers: {
    addPatient: (state, action: PayloadAction<Patient>) => {
      state.patients.push(action.payload)
    },
    updatePatient: (state, action: PayloadAction<{ id: string; changes: Partial<Patient> }>) => {
      const index = state.patients.findIndex(p => p.id === action.payload.id)
      if (index !== -1) {
        state.patients[index] = { ...state.patients[index], ...action.payload.changes, updatedAt: new Date().toISOString() }
      }
    },
    deletePatient: (state, action: PayloadAction<string>) => {
      state.patients = state.patients.filter(p => p.id !== action.payload)
    },
    setCurrentPatient: (state, action: PayloadAction<Patient | null>) => {
      state.currentPatient = action.payload
    },
    addShift: (state, action: PayloadAction<Shift>) => {
      state.shifts.push(action.payload)
    },
    updateShift: (state, action: PayloadAction<{ id: string; changes: Partial<Shift> }>) => {
      const index = state.shifts.findIndex(s => s.id === action.payload.id)
      if (index !== -1) {
        state.shifts[index] = { ...state.shifts[index], ...action.payload.changes }
      }
    },
    deleteShift: (state, action: PayloadAction<string>) => {
      state.shifts = state.shifts.filter(s => s.id !== action.payload)
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
  },
})

export const {
  addPatient,
  updatePatient,
  deletePatient,
  setCurrentPatient,
  addShift,
  updateShift,
  deleteShift,
  setLoading,
  setError,
} = patientsSlice.actions

export default patientsSlice.reducer