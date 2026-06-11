import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthActions } from '../../hooks'
import { useSettingsActions } from '../../hooks'

export const PinSetupPage = () => {
  const navigate = useNavigate()
  const { setPin, setBiometricEnabled } = useAuthActions()
  const { setPinSet } = useSettingsActions()
  const [pin, setPinValue] = useState('')
  const [confirmPin, setConfirmPin] = useState('')
  const [error, setError] = useState('')

  const handleSubmit = () => {
    if (pin.length < 4) {
      setError('El PIN debe tener al menos 4 dígitos')
      return
    }
    if (pin !== confirmPin) {
      setError('Los PINs no coinciden')
      return
    }
    setPin(true)
    setPinSet(true)
    setBiometricEnabled(false)
    navigate('/ai', { replace: true })
  }

  return (
    <div className="min-h-screen bg-deepBlack flex flex-col">
      <header className="sticky top-0 z-10 bg-deepBlack/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3">
          <h1 className="text-lg font-bold text-text-primary">Configurar PIN</h1>
        </div>
      </header>

      <div className="flex-1 px-screenPadding py-8">
        <div className="text-center mb-8">
          <div className="w-20 h-20 rounded-full bg-clinicalBlue/10 flex items-center justify-center mx-auto mb-4">
            <svg className="w-10 h-10 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6M12 19l9 2m-12 0l9-2" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-text-primary mb-2">Crea tu PIN de acceso</h2>
          <p className="text-text-secondary">Usarás este PIN para desbloquear la app rápidamente</p>
        </div>

        <div className="max-w-md mx-auto space-y-4">
          <div>
            <label className="label-clinical">PIN</label>
            <input
              type="password"
              value={pin}
              onChange={(e) => setPinValue(e.target.value)}
              maxLength={6}
              className="input-clinical text-center text-2xl tracking-widest font-mono"
              placeholder="••••"
              autoFocus
            />
          </div>
          <div>
            <label className="label-clinical">Confirmar PIN</label>
            <input
              type="password"
              value={confirmPin}
              onChange={(e) => setConfirmPin(e.target.value)}
              maxLength={6}
              className="input-clinical text-center text-2xl tracking-widest font-mono"
              placeholder="••••"
            />
          </div>
          {error && (
            <div className="p-3 bg-alert-red/10 border border-alert-red/30 rounded-lg text-sm text-alert-red text-center animate-slide-up">
              {error}
            </div>
          )}
          <button
            onClick={handleSubmit}
            disabled={pin.length < 4 || confirmPin.length < 4}
            className="w-full btn-primary mt-4"
          >
            Configurar PIN
          </button>
        </div>
      </div>
    </div>
  )
}

export default PinSetupPage