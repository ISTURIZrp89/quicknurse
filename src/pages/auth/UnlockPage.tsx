import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth, useAuthActions } from '../../hooks'

export const UnlockPage = () => {
  const navigate = useNavigate()
  const { remainingAttempts } = useAuth()
  const { logout } = useAuthActions()
  const [pin, setPin] = useState('')
  const [error, _setError] = useState('')

  useEffect(() => {
    // authenticateWithBiometrics()
  }, [])

  const handleForgotPin = () => {
    logout()
    navigate('/pin-setup', { replace: true })
  }

  return (
    <div className="min-h-screen bg-surface-bg flex flex-col">
      <header className="sticky top-0 z-10 bg-surface-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3">
          <h1 className="text-lg font-bold text-text-primary">Desbloquear</h1>
        </div>
      </header>

      <div className="flex-1 px-screenPadding py-8 flex flex-col items-center justify-center">
        <div className="text-center mb-8">
          <div className="w-20 h-20 rounded-full bg-clinicalBlue/10 flex items-center justify-center mx-auto mb-4">
            <svg className="w-10 h-10 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6M12 19l9 2m-12 0l9-2" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-text-primary mb-2">QuickNurse bloqueado</h2>
          <p className="text-text-secondary">Introduce tu PIN para continuar</p>
        </div>

        <div className="w-full max-w-md">
          <div className="grid grid-cols-4 gap-3 mb-6">
            {[1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className={`w-12 h-12 rounded-lg border-2 ${i <= pin.length ? 'bg-clinicalBlue border-clinicalBlue' : 'border-border-default bg-surface-input'}`}
              />
            ))}
          </div>

          {error && (
            <div className="p-3 bg-alert-red/10 border border-alert-red/30 rounded-lg text-sm text-alert-red text-center mb-4 animate-slide-up">
              {error}
            </div>
          )}

          <p className="text-xs text-text-disabled text-center mb-4">
            {remainingAttempts} intentos restantes
          </p>

          <div className="grid grid-cols-3 gap-3 mb-4">
            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 'backspace'].map((key) => (
              <button
                key={key}
                onClick={() => {
                  if (key === 'backspace') {
                    setPin(pin.slice(0, -1))
                  } else if (pin.length < 4) {
                    setPin(pin + key)
                  }
                }}
                className="h-14 bg-surface-card border border-border-default rounded-lg text-2xl font-medium text-text-primary hover:bg-surface-cardHover active:scale-95 transition-all"
              >
                {key === 'backspace' ? (
                  <svg className="w-6 h-6 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                ) : (
                  key
                )}
              </button>
            ))}
          </div>

          <button
            onClick={handleForgotPin}
            className="w-full text-text-secondary font-medium text-sm underline-offset-2 hover:text-text-primary"
          >
            ¿Olvidaste tu PIN?
          </button>
        </div>
      </div>
    </div>
  )
}

export default UnlockPage