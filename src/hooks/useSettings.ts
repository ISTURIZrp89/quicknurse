import { useDispatch, useSelector } from 'react-redux'
import { RootState, AppDispatch } from '../store'
import { 
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
  resetSettings
} from '../store/slices/settingsSlice'

export const useSettings = () => {
  return useSelector((state: RootState) => state.settings)
}

export const useSettingsActions = () => {
  const dispatch = useDispatch<AppDispatch>()
  
  return {
    setBiometricEnabled: (enabled: boolean) => dispatch(setBiometricEnabled(enabled)),
    setAutoLockMinutes: (minutes: number) => dispatch(setAutoLockMinutes(minutes)),
    setScreenCaptureBlocked: (blocked: boolean) => dispatch(setScreenCaptureBlocked(blocked)),
    setPinSet: (set: boolean) => dispatch(setPinSet(set)),
    setAiEnabled: (enabled: boolean) => dispatch(setAiEnabled(enabled)),
    setAiModel: (model: string) => dispatch(setAiModel(model)),
    setAiContextSize: (size: number) => dispatch(setAiContextSize(size)),
    setAiTemperature: (temp: number) => dispatch(setAiTemperature(temp)),
    setFontScale: (scale: number) => dispatch(setFontScale(scale)),
    setReducedMotion: (enabled: boolean) => dispatch(setReducedMotion(enabled)),
    setPushEnabled: (enabled: boolean) => dispatch(setPushEnabled(enabled)),
    setVibrationEnabled: (enabled: boolean) => dispatch(setVibrationEnabled(enabled)),
    setSoundEnabled: (enabled: boolean) => dispatch(setSoundEnabled(enabled)),
    resetSettings: () => dispatch(resetSettings()),
  }
}