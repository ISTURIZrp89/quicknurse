import { useDispatch, useSelector } from 'react-redux'
import { RootState, AppDispatch } from '../store'
import { 
  loginSuccess, 
  logout, 
  setLoading, 
  setError, 
  setPin, 
  setBiometricEnabled,
  setRemainingAttempts,
  setLockedUntil,
  clearError,
  checkStatus,
  setStatus,
  authenticateWithGoogle,
  authenticateWithGoogleSuccess,
  authenticateWithGoogleFailure,
  skipLogin,
  authenticateWithPin,
  authenticateWithBiometrics,
  setupPin,
  lock
} from '../store/slices/authSlice'

export const useAuth = () => {
  return useSelector((state: RootState) => state.auth)
}

export const useAuthActions = () => {
  const dispatch = useDispatch<AppDispatch>()
  
  return {
    login: (user: any) => dispatch(loginSuccess(user)),
    logout: () => dispatch(logout()),
    setLoading: (loading: boolean) => dispatch(setLoading(loading)),
    setError: (error: string | null) => dispatch(setError(error)),
    clearError: () => dispatch(clearError()),
    setPin: (pinSet: boolean) => dispatch(setPin(pinSet)),
    setBiometricEnabled: (enabled: boolean) => dispatch(setBiometricEnabled(enabled)),
    setRemainingAttempts: (attempts: number) => dispatch(setRemainingAttempts(attempts)),
    setLockedUntil: (lockedUntil: string | null) => dispatch(setLockedUntil(lockedUntil)),
    checkStatus: () => dispatch(checkStatus()),
    setStatus: (status: any) => dispatch(setStatus(status)),
    authenticateWithGoogle: () => dispatch(authenticateWithGoogle()),
    authenticateWithGoogleSuccess: (user: any) => dispatch(authenticateWithGoogleSuccess(user)),
    authenticateWithGoogleFailure: (error: string) => dispatch(authenticateWithGoogleFailure(error)),
    skipLogin: () => dispatch(skipLogin()),
    authenticateWithPin: (pin: string) => dispatch(authenticateWithPin(pin)),
    authenticateWithBiometrics: () => dispatch(authenticateWithBiometrics()),
    setupPin: (pin: string) => dispatch(setupPin(pin)),
    lock: () => dispatch(lock()),
  }
}