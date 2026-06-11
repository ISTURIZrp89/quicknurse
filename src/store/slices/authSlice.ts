import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface User {
  id: string
  email: string
  name: string
  role: 'nurse' | 'student' | 'admin'
  avatar?: string
}

export interface AuthState {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
  pinSet: boolean
  biometricEnabled: boolean
  remainingAttempts: number
  lockedUntil: string | null
  status: 'unauthenticated' | 'authenticated' | 'firstTime' | 'loading'
  errorMessage: string | null
}

const initialState: AuthState = {
  user: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
  errorMessage: null,
  pinSet: false,
  biometricEnabled: false,
  remainingAttempts: 5,
  lockedUntil: null,
  status: 'loading',
}

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
    loginSuccess: (state, action: PayloadAction<User>) => {
      state.user = action.payload
      state.isAuthenticated = true
      state.isLoading = false
      state.error = null
      state.errorMessage = null
      state.remainingAttempts = 5
      state.status = 'authenticated'
    },
    logout: (state) => {
      state.user = null
      state.isAuthenticated = false
      state.error = null
      state.errorMessage = null
      state.status = 'unauthenticated'
    },
    setPin: (state, action: PayloadAction<boolean>) => {
      state.pinSet = action.payload
      if (action.payload) state.status = 'authenticated'
    },
    setBiometricEnabled: (state, action: PayloadAction<boolean>) => {
      state.biometricEnabled = action.payload
    },
    setRemainingAttempts: (state, action: PayloadAction<number>) => {
      state.remainingAttempts = action.payload
    },
    setLockedUntil: (state, action: PayloadAction<string | null>) => {
      state.lockedUntil = action.payload
    },
    clearError: (state) => {
      state.error = null
      state.errorMessage = null
    },
    setStatus: (state, action: PayloadAction<AuthState['status']>) => {
      state.status = action.payload
    },
    checkStatus: (state) => {
      if (!state.pinSet) {
        state.status = 'firstTime'
      } else {
        state.status = 'unauthenticated'
      }
    },
    authenticateWithGoogle: (state) => {
      state.isLoading = true
    },
    authenticateWithGoogleSuccess: (state, action: PayloadAction<User>) => {
      state.user = action.payload
      state.isAuthenticated = true
      state.isLoading = false
      state.error = null
      state.remainingAttempts = 5
      state.status = 'authenticated'
    },
    authenticateWithGoogleFailure: (state, action: PayloadAction<string>) => {
      state.isLoading = false
      state.errorMessage = action.payload
    },
    skipLogin: (state) => {
      state.isAuthenticated = true
      state.status = 'authenticated'
      state.user = { id: 'guest', email: '', name: 'Usuario', role: 'nurse' }
    },
    authenticateWithPin: (_state, _action: PayloadAction<string>) => {
      // PIN verification logic would go here
    },
    authenticateWithBiometrics: (_state) => {
      // Biometric verification logic
    },
    setupPin: (state, _action: PayloadAction<string>) => {
      state.pinSet = true
      state.status = 'authenticated'
    },
    lock: (state) => {
      state.status = 'unauthenticated'
    },
  },
})

export const {
  setLoading,
  setError,
  loginSuccess,
  logout,
  setPin,
  setBiometricEnabled,
  setRemainingAttempts,
  setLockedUntil,
  clearError,
  setStatus,
  checkStatus,
  authenticateWithGoogle,
  authenticateWithGoogleSuccess,
  authenticateWithGoogleFailure,
  skipLogin,
  authenticateWithPin,
  authenticateWithBiometrics,
  setupPin,
  lock,
} = authSlice.actions

export default authSlice.reducer