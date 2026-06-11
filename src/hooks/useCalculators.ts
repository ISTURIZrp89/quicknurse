import { useDispatch, useSelector } from 'react-redux'
import { RootState, AppDispatch } from '../store'
import { 
  setFormula, 
  updateParameter, 
  setResult, 
  setLoading, 
  setError, 
  resetCalculator, 
  clearHistory, 
  removeHistoryItem 
} from '../store/slices/calculatorsSlice'

export const useCalculators = () => {
  return useSelector((state: RootState) => state.calculators)
}

export const useCalculatorsActions = () => {
  const dispatch = useDispatch<AppDispatch>()
  
  return {
    setFormula: (formula: string) => dispatch(setFormula(formula)),
    updateParameter: (name: string, value: number | string | boolean) => dispatch(updateParameter({ name, value })),
    setResult: (result: any) => dispatch(setResult(result)),
    setLoading: (loading: boolean) => dispatch(setLoading(loading)),
    setError: (error: string | null) => dispatch(setError(error)),
    resetCalculator: () => dispatch(resetCalculator()),
    clearHistory: () => dispatch(clearHistory()),
    removeHistoryItem: (index: number) => dispatch(removeHistoryItem(index)),
  }
}