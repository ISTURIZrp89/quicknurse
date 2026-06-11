import { useDispatch, useSelector } from 'react-redux'
import { RootState, AppDispatch } from '../store'
import { 
  addPatient, 
  updatePatient, 
  deletePatient, 
  setCurrentPatient,
  addShift,
  updateShift,
  deleteShift,
  setLoading,
  setError
} from '../store/slices/patientsSlice'

export const usePatients = () => {
  return useSelector((state: RootState) => state.patients)
}

export const usePatientsActions = () => {
  const dispatch = useDispatch<AppDispatch>()
  
  return {
    addPatient: (patient: any) => dispatch(addPatient(patient)),
    updatePatient: (id: string, changes: any) => dispatch(updatePatient({ id, changes })),
    deletePatient: (id: string) => dispatch(deletePatient(id)),
    setCurrentPatient: (patient: any | null) => dispatch(setCurrentPatient(patient)),
    addShift: (shift: any) => dispatch(addShift(shift)),
    updateShift: (id: string, changes: any) => dispatch(updateShift({ id, changes })),
    deleteShift: (id: string) => dispatch(deleteShift(id)),
    setLoading: (loading: boolean) => dispatch(setLoading(loading)),
    setError: (error: string | null) => dispatch(setError(error)),
  }
}