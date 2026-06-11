import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './hooks'
import { SplashScreen } from './pages/SplashScreen'
import { LoginPage } from './pages/auth/LoginPage'
import { PinSetupPage } from './pages/auth/PinSetupPage'
import { UnlockPage } from './pages/auth/UnlockPage'
import { CalculatorsPage } from './pages/calculators/CalculatorsPage'
import { CalculatorDetailPage } from './pages/calculators/CalculatorDetailPage'
import { AIPage } from './pages/ai/AIPage'
import { SettingsPage } from './pages/settings/SettingsPage'
import { PatientsPage } from './pages/patients/PatientsPage'
import { PatientDetailPage } from './pages/patients/PatientDetailPage'
import { ShiftsPage } from './pages/shifts/ShiftsPage'
import BottomNav from './components/common/BottomNav'

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated } = useAuth()
  if (isAuthenticated) return <>{children}</>
  return <Navigate to="/login" replace />
}

const PublicRoute = ({ children }: { children: React.ReactNode }) => {
  const { status } = useAuth()
  if (status === 'unauthenticated' || status === 'firstTime') return <>{children}</>
  return <Navigate to="/ai" replace />
}

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/splash" element={<SplashScreen />} />
      <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
      <Route path="/pin-setup" element={<PublicRoute><PinSetupPage /></PublicRoute>} />
      <Route path="/unlock" element={<ProtectedRoute><UnlockPage /></ProtectedRoute>} />
      
      <Route path="/ai" element={<ProtectedRoute><AIPage /></ProtectedRoute>} />
      <Route path="/calculators" element={<ProtectedRoute><CalculatorsPage /></ProtectedRoute>} />
      <Route path="/calculators/:type" element={<ProtectedRoute><CalculatorDetailPage /></ProtectedRoute>} />
      <Route path="/patients" element={<ProtectedRoute><PatientsPage /></ProtectedRoute>} />
      <Route path="/patients/:id" element={<ProtectedRoute><PatientDetailPage /></ProtectedRoute>} />
      <Route path="/shifts" element={<ProtectedRoute><ShiftsPage /></ProtectedRoute>} />
      <Route path="/settings" element={<ProtectedRoute><SettingsPage /></ProtectedRoute>} />
      <Route path="/" element={<Navigate to="/ai" replace />} />
      <Route path="*" element={<Navigate to="/ai" replace />} />
    </Routes>
  )
}

export const App = () => {
  return (
    <div className="min-h-screen bg-surface-bg">
      <AppRoutes />
      <BottomNav />
    </div>
  )
}