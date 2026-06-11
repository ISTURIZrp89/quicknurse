import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface SettingsState {
  // Seguridad
  biometricEnabled: boolean
  autoLockMinutes: number
  screenCaptureBlocked: boolean
  pinSet: boolean

  // IA
  aiEnabled: boolean
  aiModel: string
  aiContextSize: number
  aiTemperature: number

  // Apariencia
  theme: 'dark' // Solo dark mode
  fontScale: number
  reducedMotion: boolean

  // Notificaciones
  pushEnabled: boolean
  vibrationEnabled: boolean
  soundEnabled: boolean
}

const initialState: SettingsState = {
  biometricEnabled: false,
  autoLockMinutes: 5,
  screenCaptureBlocked: true,
  pinSet: false,
  aiEnabled: true,
  aiModel: 'biomistral-7b-q4',
  aiContextSize: 4096,
  aiTemperature: 0.3,
  theme: 'dark',
  fontScale: 1.0,
  reducedMotion: false,
  pushEnabled: true,
  vibrationEnabled: true,
  soundEnabled: true,
}

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setBiometricEnabled: (state, action: PayloadAction<boolean>) => {
      state.biometricEnabled = action.payload
    },
    setAutoLockMinutes: (state, action: PayloadAction<number>) => {
      state.autoLockMinutes = action.payload
    },
    setScreenCaptureBlocked: (state, action: PayloadAction<boolean>) => {
      state.screenCaptureBlocked = action.payload
    },
    setPinSet: (state, action: PayloadAction<boolean>) => {
      state.pinSet = action.payload
    },
    setAiEnabled: (state, action: PayloadAction<boolean>) => {
      state.aiEnabled = action.payload
    },
    setAiModel: (state, action: PayloadAction<string>) => {
      state.aiModel = action.payload
    },
    setAiContextSize: (state, action: PayloadAction<number>) => {
      state.aiContextSize = action.payload
    },
    setAiTemperature: (state, action: PayloadAction<number>) => {
      state.aiTemperature = action.payload
    },
    setFontScale: (state, action: PayloadAction<number>) => {
      state.fontScale = Math.max(0.8, Math.min(1.5, action.payload))
    },
    setReducedMotion: (state, action: PayloadAction<boolean>) => {
      state.reducedMotion = action.payload
    },
    setPushEnabled: (state, action: PayloadAction<boolean>) => {
      state.pushEnabled = action.payload
    },
    setVibrationEnabled: (state, action: PayloadAction<boolean>) => {
      state.vibrationEnabled = action.payload
    },
    setSoundEnabled: (state, action: PayloadAction<boolean>) => {
      state.soundEnabled = action.payload
    },
    resetSettings: () => initialState,
  },
})

export const {
  setBiometricEnabled,
  setAutoLockMinutes,
  setScreenCaptureBlocked,
  setPinSet,
  setAiEnabled,
  setAiModel,
  setAiContextSize,
  setAiTemperature,
  setFontScale,
  setReducedMotion,
  setPushEnabled,
  setVibrationEnabled,
  setSoundEnabled,
  resetSettings,
} = settingsSlice.actions

export default settingsSlice.reducer