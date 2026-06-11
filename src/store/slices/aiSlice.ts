import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface AIModel {
  id: string
  name: string
  path: string
  size: number
  modelType: string
  quantization: string
  isLoaded: boolean
  isPremium: boolean
}

export interface AIMessage {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: string
  category: 'general' | 'pharmacologic' | 'interaction' | 'clinicalSummary' | 'vitalInterpretation' | 'recommendation'
  confidence?: number
}

export interface ClinicalContext {
  patientAge?: number
  patientWeight?: number
  patientGender?: 'male' | 'female' | 'other'
  vitalSigns?: Record<string, number>
  medications?: string[]
  diagnoses?: string[]
  allergies?: string[]
  recentNotes?: string
  hasPatientData: boolean
}

export interface AIState {
  isLoaded: boolean
  isLoading: boolean
  selectedModel: AIModel | null
  models: AIModel[]
  conversationHistory: AIMessage[]
  clinicalContext: ClinicalContext | null
  currentResponse: string | null
  error: string | null
  downloadProgress: number
  memoryUsage: number
}

const initialState: AIState = {
  isLoaded: false,
  isLoading: false,
  selectedModel: null,
  models: [],
  conversationHistory: [],
  clinicalContext: null,
  currentResponse: null,
  error: null,
  downloadProgress: 0,
  memoryUsage: 0,
}

const aiSlice = createSlice({
  name: 'ai',
  initialState,
  reducers: {
    setModels: (state, action: PayloadAction<any[]>) => {
      state.models = action.payload
    },
    setSelectedModel: (state, action: PayloadAction<any>) => {
      state.selectedModel = action.payload
    },
    setLoaded: (state, action: PayloadAction<boolean>) => {
      state.isLoaded = action.payload
      state.isLoading = false
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
      state.isLoading = false
    },
    addMessage: (state, action: PayloadAction<any>) => {
      state.conversationHistory.push(action.payload)
    },
    clearHistory: (state) => {
      state.conversationHistory = []
    },
    setClinicalContext: (state, action: PayloadAction<any>) => {
      state.clinicalContext = action.payload
    },
    setDownloadProgress: (state, action: PayloadAction<number>) => {
      state.downloadProgress = action.payload
    },
    setMemoryUsage: (state, action: PayloadAction<number>) => {
      state.memoryUsage = action.payload
    },
    setCurrentResponse: (state, action: PayloadAction<string | null>) => {
      state.currentResponse = action.payload
    },
    clearError: (state) => {
      state.error = null
    },
    loadModel: (state, action: PayloadAction<string>) => {
      state.isLoading = true
      state.selectedModel = state.models.find(m => m.id === action.payload) || null
    },
    unloadModel: (state) => {
      state.isLoaded = false
      state.selectedModel = null
    },
    sendMessage: (state, action: PayloadAction<string>) => {
      state.conversationHistory.push({
        id: Date.now().toString(),
        role: 'user',
        content: action.payload,
        timestamp: new Date().toISOString(),
        category: 'general',
      })
      state.isLoading = true
    },
    analyzeMedication: (state, action: PayloadAction<string>) => {
      state.conversationHistory.push({
        id: Date.now().toString(),
        role: 'user',
        content: `Analizar medicamento: ${action.payload}`,
        timestamp: new Date().toISOString(),
        category: 'pharmacologic',
      })
      state.isLoading = true
    },
    generateSummary: (state) => {
      state.isLoading = true
    },
    analyzeVitals: (state, action: PayloadAction<any>) => {
      state.conversationHistory.push({
        id: Date.now().toString(),
        role: 'user',
        content: `Interpretar signos vitales: ${JSON.stringify(action.payload)}`,
        timestamp: new Date().toISOString(),
        category: 'vitalInterpretation',
      })
      state.isLoading = true
    },
    downloadModel: (state) => {
      state.isLoading = true
      state.downloadProgress = 0
    },
    clearResponse: (state) => {
      state.currentResponse = null
    },
    clearConversation: (state) => {
      state.conversationHistory = []
    },
  },
})

export const {
  setModels,
  setSelectedModel,
  setLoaded,
  setLoading,
  setError,
  addMessage,
  clearHistory,
  setClinicalContext,
  setDownloadProgress,
  setMemoryUsage,
  setCurrentResponse,
  clearError,
  loadModel,
  unloadModel,
  sendMessage,
  analyzeMedication,
  generateSummary,
  analyzeVitals,
  downloadModel,
  clearResponse,
  clearConversation,
} = aiSlice.actions

export default aiSlice.reducer