import { useAuth, useAuthActions } from '../../hooks'
import { useSettingsActions } from '../../hooks'

export const LoginPage = () => {
  const { errorMessage } = useAuth()
  const { authenticateWithGoogle } = useAuthActions()
  const { setBiometricEnabled } = useSettingsActions()

  const handleGoogleSignIn = async () => {
    try {
      const success = await authenticateWithGoogle()
      if (success) {
        window.location.href = '/ai'
      }
    } catch (error) {
      console.error('Google sign-in error:', error)
    }
  }

  const handleSkipLogin = () => {
    localStorage.setItem('biometricEnabled', 'false')
    setBiometricEnabled(false)
    window.location.href = '/ai'
  }

  return (
    <div className="min-h-screen flex flex-col bg-deepBlack">
      <div className="flex-1 flex flex-col items-center justify-center px-screenPadding">
        <div className="w-22 h-22 rounded-full bg-gradient-to-br from-clinicalBlue to-monitorGreen flex items-center justify-center mb-6 shadow-clinical">
          <svg className="w-11 h-11 text-white" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
          </svg>
        </div>

        <h1 className="text-3xl font-bold text-text-primary tracking-wide mb-2 text-center">
          QuickNurse
        </h1>
        <p className="text-text-secondary text-center mb-12 max-w-xs mx-auto">
          Tu asistente clínico inteligente. Acceso seguro, IA local, 19 calculadoras.
        </p>

        <button
          onClick={handleGoogleSignIn}
          className="w-full btn-secondary flex items-center justify-center gap-3 mb-4"
        >
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.34-2.66l-3.9-2.81c-.82.66-1.83.86-3.1.86-2.87 0-5.29-1.93-6.14-4.46H1.92v2.94C3.8 17.82 7.64 21 12 21c4.15 0 7.22-2.43 8.56-5.75z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H3.21c-.06.72-.1 1.46-.1 2.18 0 1.63.22 3.2.6 4.18L2.1 14.73c1.63 1.88 4.13 2.89 7.03 2.89 1.26 0 2.47-.23 3.54-.64l2.88 2.21c-.98 1.56-2.58 2.72-4.48 2.72z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.32-3.32C17.46 2.93 15.34 2 12 2 8.3 2 3.73 5.65 1.96 10.4L0 8.81C3.45 5.2 7.3 3 12 3c3.78 0 6.89 2.55 7.99 5.92l-3.33 3.31c-.82-1.6-2.1-2.76-3.66-2.76z"/>
          </svg>
          <span>Iniciar sesión con Google</span>
        </button>

        <p className="text-xs text-text-disabled text-center mb-6 px-4">
          Al iniciar sesión aceptas los términos y condiciones
        </p>

        <button
          onClick={handleSkipLogin}
          className="text-text-secondary font-medium text-sm underline-offset-2 hover:underline"
        >
          Omitir por ahora
        </button>

        {errorMessage && (
          <div className="mt-4 p-3 bg-alert-red/10 border border-alert-red/30 rounded-lg text-sm text-alert-red text-center animate-slide-up">
            {errorMessage}
          </div>
        )}
      </div>
    </div>
  )
}

export default LoginPage