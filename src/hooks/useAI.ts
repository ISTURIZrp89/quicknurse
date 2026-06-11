import { useDispatch, useSelector } from 'react-redux'
import { RootState, AppDispatch } from '../store'
import { 
  loadModel, 
  unloadModel, 
  sendMessage, 
  analyzeMedication, 
  generateSummary, 
  analyzeVitals, 
  downloadModel, 
  clearResponse, 
  clearConversation,
  setClinicalContext 
} from '../store/slices/aiSlice'

export const useAI = () => {
  return useSelector((state: RootState) => state.ai)
}

export const useAIActions = () => {
  const dispatch = useDispatch<AppDispatch>()
  
  return {
    loadModel: (modelId: string) => dispatch(loadModel(modelId)),
    unloadModel: () => dispatch(unloadModel()),
    sendMessage: (message: string) => dispatch(sendMessage(message)),
    analyzeMedication: (medication: string) => dispatch(analyzeMedication(medication)),
    generateSummary: () => dispatch(generateSummary()),
    analyzeVitals: (vitals: any) => dispatch(analyzeVitals(vitals)),
    downloadModel: () => dispatch(downloadModel()),
    clearResponse: () => dispatch(clearResponse()),
    clearConversation: () => dispatch(clearConversation()),
    setClinicalContext: (context: any) => dispatch(setClinicalContext(context)),
  }
}