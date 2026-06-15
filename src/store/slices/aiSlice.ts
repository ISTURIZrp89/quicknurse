import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit'
import { modelManager, generateResponse, formatClinicalPrompt, AI_MODELS } from '../../services/ai/aiService'
import { RootState } from '../store'

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
  isGenerating: boolean
}

const initialState: AIState = {
  isLoaded: false,
  isLoading: false,
  selectedModel: null,
  models: Object.values(AI_MODELS).map(m => ({
    ...m,
    path: '',
    size: m.size,
    isLoaded: false,
  })),
  conversationHistory: [],
  clinicalContext: null,
  currentResponse: null,
  error: null,
  downloadProgress: 0,
  memoryUsage: 0,
  isGenerating: false,
}

// Async thunks
export const loadModel = createAsyncThunk(
  'ai/loadModel',
  async (modelId: string, { dispatch, rejectWithValue }) => {
    try {
      dispatch(setLoading(true))
      await modelManager.loadModel(modelId)
      dispatch(setLoaded({ modelId, loaded: true }))
      return modelId
    } catch (error) {
      dispatch(setError(error instanceof Error ? error.message : 'Error cargando modelo'))
      return rejectWithValue(error instanceof Error ? error.message : 'Error cargando modelo')
    }
  }
)

export const unloadModel = createAsyncThunk(
  'ai/unloadModel',
  async (_, { dispatch }) => {
    await modelManager.unloadAll()
    dispatch(setLoaded({ modelId: '', loaded: false }))
  }
)

export const downloadModel = createAsyncThunk(
  'ai/downloadModel',
  async (modelId: string, { dispatch, rejectWithValue }) => {
    try {
      dispatch(setLoading(true))
      dispatch(setDownloadProgress(0))
      
      await modelManager.downloadModel(modelId, (progress) => {
        dispatch(setDownloadProgress(progress))
      })
      
      dispatch(setDownloadProgress(100))
      return modelId
    } catch (error) {
      dispatch(setError(error instanceof Error ? error.message : 'Error descargando modelo'))
      return rejectWithValue(error instanceof Error ? error.message : 'Error descargando modelo')
    }
  }
)

export const sendMessage = createAsyncThunk(
  'ai/sendMessage',
  async (message: string, { getState, rejectWithValue }) => {
    const state = getState() as RootState
    const { selectedModel, clinicalContext } = state.ai
    
    if (!selectedModel || !selectedModel.isLoaded) {
      return rejectWithValue('No hay modelo cargado')
    }
    
    try {
      const prompt = formatClinicalPrompt(message, {
        ...clinicalContext!,
        category: 'general',
        hasPatientData: clinicalContext?.hasPatientData || false,
      })
      
      let fullResponse = ''
      
      const response = await generateResponse(
        selectedModel.id,
        prompt,
        512,
        (token) => {
          fullResponse += token
        }
      )
      
      return {
        userMessage: message,
        assistantResponse: fullResponse || response,
      }
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Error generando respuesta')
    }
  }
)

export const analyzeMedication = createAsyncThunk(
  'ai/analyzeMedication',
  async (medication: string, { getState, rejectWithValue }) => {
    const state = getState() as RootState
    const { selectedModel, clinicalContext } = state.ai
    
    if (!selectedModel || !selectedModel.isLoaded) {
      return rejectWithValue('No hay modelo cargado')
    }
    
    try {
      const prompt = formatClinicalPrompt(
        `Analiza el medicamento: ${medication}`,
        {
          ...clinicalContext!,
          category: 'pharmacologic',
          hasPatientData: clinicalContext?.hasPatientData || false,
        }
      )
      
      let fullResponse = ''
      const response = await generateResponse(
        selectedModel.id,
        prompt,
        512,
        (token) => { fullResponse += token }
      )
      
      return fullResponse || response
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Error analizando medicamento')
    }
  }
)

export const generateSummary = createAsyncThunk(
  'ai/generateSummary',
  async (_, { getState, rejectWithValue }) => {
    const state = getState() as RootState
    const { selectedModel, clinicalContext, conversationHistory } = state.ai
    
    if (!selectedModel || !selectedModel.isLoaded) {
      return rejectWithValue('No hay modelo cargado')
    }
    
    try {
      const contextSummary = conversationHistory
        .map(m => `${m.role}: ${m.content}`)
        .join('\n')
      
      const prompt = formatClinicalPrompt(
        `Genera un resumen clínico basado en la conversación:\n${contextSummary}`,
        {
          ...clinicalContext!,
          category: 'clinicalSummary',
          hasPatientData: clinicalContext?.hasPatientData || false,
        }
      )
      
      let fullResponse = ''
      const response = await generateResponse(
        selectedModel.id,
        prompt,
        512,
        (token) => { fullResponse += token }
      )
      
      return fullResponse || response
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Error generando resumen')
    }
  }
)

export const analyzeVitals = createAsyncThunk(
  'ai/analyzeVitals',
  async (vitals: Record<string, number>, { getState, rejectWithValue }) => {
    const state = getState() as RootState
    const { selectedModel, clinicalContext } = state.ai
    
    if (!selectedModel || !selectedModel.isLoaded) {
      return rejectWithValue('No hay modelo cargado')
    }
    
    try {
      const prompt = formatClinicalPrompt(
        `Interpreta estos signos vitales: ${JSON.stringify(vitals)}`,
        {
          ...clinicalContext!,
          vitalSigns: vitals,
          category: 'vitalInterpretation',
          hasPatientData: clinicalContext?.hasPatientData || false,
        }
      )
      
      let fullResponse = ''
      const response = await generateResponse(
        selectedModel.id,
        prompt,
        512,
        (token) => { fullResponse += token }
      )
      
      return fullResponse || response
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Error interpretando signos vitales')
    }
  }
)

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
    setLoaded: (state, action: PayloadAction<{ modelId: string; loaded: boolean }>) => {
      if (action.payload.loaded && action.payload.modelId) {
        const model = state.models.find(m => m.id === action.payload.modelId)
        if (model) {
          model.isLoaded = true
          state.selectedModel = model
        }
      }
      state.isLoaded = action.payload.loaded
      state.isLoading = false
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
      state.isLoading = false
      state.isGenerating = false
    },
    addMessage: (state, action: PayloadAction<AIMessage>) => {
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
    setGenerating: (state, action: PayloadAction<boolean>) => {
      state.isGenerating = action.payload
    },
  },
  extraReducers: (builder) => {
    builder
      // loadModel
      .addCase(loadModel.pending, (state) => {
        state.isLoading = true
        state.error = null
      })
      .addCase(loadModel.fulfilled, (state, action) => {
        state.isLoading = false
        const model = state.models.find(m => m.id === action.payload)
        if (model) {
          model.isLoaded = true
          state.selectedModel = model
        }
        state.isLoaded = true
      })
      .addCase(loadModel.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.payload as string
      })
      // unloadModel
      .addCase(unloadModel.fulfilled, (state) => {
        state.isLoaded = false
        state.selectedModel = null
        state.models.forEach(m => m.isLoaded = false)
      })
      // downloadModel
      .addCase(downloadModel.pending, (state) => {
        state.isLoading = true
        state.downloadProgress = 0
      })
      .addCase(downloadModel.fulfilled, (state, action) => {
        state.isLoading = false
        state.downloadProgress = 100
        const model = state.models.find(m => m.id === action.payload)
        if (model) model.path = 'downloaded'
      })
      .addCase(downloadModel.rejected, (state, action) => {
        state.isLoading = false
        state.error = action.payload as string
      })
      // sendMessage
      .addCase(sendMessage.pending, (state) => {
        state.isGenerating = true
        state.error = null
        state.currentResponse = ''
      })
      .addCase(sendMessage.fulfilled, (state, action) => {
        state.isGenerating = false
        // Add user message
        state.conversationHistory.push({
          id: Date.now().toString(),
          role: 'user',
          content: action.payload.userMessage,
          timestamp: new Date().toISOString(),
          category: 'general',
        })
        // Add assistant response
        state.conversationHistory.push({
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: action.payload.assistantResponse,
          timestamp: new Date().toISOString(),
          category: 'general',
        })
        state.currentResponse = null
      })
      .addCase(sendMessage.rejected, (state, action) => {
        state.isGenerating = false
        state.error = action.payload as string
        state.currentResponse = null
      })
      // analyzeMedication
      .addCase(analyzeMedication.pending, (state) => {
        state.isGenerating = true
        state.error = null
      })
      .addCase(analyzeMedication.fulfilled, (state, action) => {
        state.isGenerating = false
        state.conversationHistory.push({
          id: Date.now().toString(),
          role: 'assistant',
          content: action.payload,
          timestamp: new Date().toISOString(),
          category: 'pharmacologic',
        })
      })
      .addCase(analyzeMedication.rejected, (state, action) => {
        state.isGenerating = false
        state.error = action.payload as string
      })
      // generateSummary
      .addCase(generateSummary.pending, (state) => {
        state.isGenerating = true
        state.error = null
      })
      .addCase(generateSummary.fulfilled, (state, action) => {
        state.isGenerating = false
        state.conversationHistory.push({
          id: Date.now().toString(),
          role: 'assistant',
          content: action.payload,
          timestamp: new Date().toISOString(),
          category: 'clinicalSummary',
        })
      })
      .addCase(generateSummary.rejected, (state, action) => {
        state.isGenerating = false
        state.error = action.payload as string
      })
      // analyzeVitals
      .addCase(analyzeVitals.pending, (state) => {
        state.isGenerating = true
        state.error = null
      })
      .addCase(analyzeVitals.fulfilled, (state, action) => {
        state.isGenerating = false
        state.conversationHistory.push({
          id: Date.now().toString(),
          role: 'assistant',
          content: action.payload,
          timestamp: new Date().toISOString(),
          category: 'vitalInterpretation',
        })
      })
      .addCase(analyzeVitals.rejected, (state, action) => {
        state.isGenerating = false
        state.error = action.payload as string
      })
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
  clearConversation,
  setClinicalContext,
  setDownloadProgress,
  setMemoryUsage,
  setCurrentResponse,
  clearError,
  setGenerating,
} = aiSlice.actions

export default aiSlice.reducer