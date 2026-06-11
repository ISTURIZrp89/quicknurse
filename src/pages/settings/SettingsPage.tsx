import { useSettings } from '../../hooks'
import { useSettingsActions } from '../../hooks'

export const SettingsPage = () => {
  const { 
    biometricEnabled, 
    autoLockMinutes, 
    screenCaptureBlocked,
    aiEnabled,
    aiModel,
    aiContextSize,
    aiTemperature,
  } = useSettings()
  const { setBiometricEnabled, setAutoLockMinutes, setScreenCaptureBlocked, setAiEnabled, setAiModel, setAiContextSize, setAiTemperature } = useSettingsActions()

  return (
    <div className="min-h-screen bg-deepBlack">
      <header className="sticky top-0 z-10 bg-dark-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-4 flex items-center justify-between">
          <h1 className="text-xl font-bold text-text-primary">Configuración</h1>
          <button className="text-text-secondary hover:text-text-primary">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </header>

      <div className="max-w-2xl mx-auto p-screenPadding pb-20">
        <section className="mb-8">
          <h2 className="text-xs font-bold text-clinicalBlue uppercase tracking-wider mb-4">SEGURIDAD</h2>
          <div className="bg-dark-card rounded-xl border border-border-default overflow-hidden">
            <label className="flex items-center justify-between p-4 border-b border-border-default cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                  <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622v3.784C5.612 19.401 5 20.15 5 21h14c0-.85-.595-1.65-1.405-1.935A12.02 12.02 0 0121 9c0-2.482-1.789-4.9-4.5-5.75V5" />
                  </svg>
                </div>
                <div>
                  <p className="font-medium text-text-primary">Biometría</p>
                  <p className="text-xs text-text-secondary">Autenticación con huella o rostro</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={biometricEnabled}
                onChange={(e) => setBiometricEnabled(e.target.checked)}
                className="w-5 h-5 text-clinicalBlue rounded border-border-default focus:ring-clinicalBlue"
              />
            </label>
            <div className="border-t border-border-default p-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                  <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6M12 19l9 2m-12 0l9-2m-10.5 0l4.5-3.5M12 19l9 2m-12 0l-9 2m-10.5 0l4.5 3.5" />
                  </svg>
                </div>
                <div>
                  <p className="font-medium text-text-primary">Bloqueo automático</p>
                  <p className="text-xs text-text-secondary">Tiempo de inactividad para bloquear</p>
                </div>
              </div>
              <select
                className="px-3 py-1.5 bg-dark-input border border-border-default rounded-lg text-text-primary text-sm"
                value={autoLockMinutes.toString()}
                onChange={(e) => setAutoLockMinutes(parseInt(e.target.value))}
              >
                <option value="1">1 minuto</option>
                <option value="5">5 minutos</option>
                <option value="15">15 minutos</option>
                <option value="30">30 minutos</option>
              </select>
            </div>
            <div className="p-4 flex items-center justify-between border-t border-border-default cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                  <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622v3.784C5.612 19.401 5 20.15 5 21h14c0-.85-.595-1.65-1.405-1.935A12.02 12.02 0 0121 9c0-2.482-1.789-4.9-4.5-5.75V5" />
                  </svg>
                </div>
                <div>
                  <p className="font-medium text-text-primary">Bloquear captura de pantalla</p>
                  <p className="text-xs text-text-secondary">Evita capturas en la app</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={screenCaptureBlocked}
                onChange={(e) => setScreenCaptureBlocked(e.target.checked)}
                className="w-5 h-5 text-clinicalBlue rounded border-border-default focus:ring-clinicalBlue"
              />
            </div>
          </div>
        </section>

        <section className="mb-8">
          <h2 className="text-xs font-bold text-clinicalBlue uppercase tracking-wider mb-4">INTELIGENCIA ARTIFICIAL</h2>
          <div className="bg-dark-card rounded-xl border border-border-default overflow-hidden">
            <label className="flex items-center justify-between p-4 border-b border-border-default cursor-pointer">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                  <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9.663 17h4.673M12 3v1m6.364 1.66l-1.21 1.21M21 12h-1.86M21 12l-1.21 1.21M3.342 19.598l1.21-1.21M10.5 4.514a3.136 3.136 0 012.88-1.105l-.023.01zM18 10.414a4.486 4.486 0 01-2.923 5.85M4.493 19.707A6.432 6.432 0 012 14.71a10.97 10.97 0 019.548.528l1.414-1.414a10.971 10.971 0 015.361.885 3.136 3.136 0 01-.163 2.39 15.986 15.986 0 01-3.137 5.114 15.92 15.92 0 01-9.218-4.677z" />
                  </svg>
                </div>
                <div>
                  <p className="font-medium text-text-primary">IA Clínica</p>
                  <p className="text-xs text-text-secondary">Asistente con modelos locales</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={aiEnabled}
                onChange={(e) => setAiEnabled(e.target.checked)}
                className="w-5 h-5 text-clinicalBlue rounded border-border-default focus:ring-clinicalBlue"
              />
            </label>
            <div className="p-4 border-t border-border-default">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                    <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M19.429 15.429a11.955 11.955 0 01-8.618 3.04A11.955 11.955 0 013 12a11.955 11.955 0 018.344-6.404M15 11.105v5.598M9 15v-.5l2.238-2.238a12.06 12.06 0 01.983-2.196 15.49 15.49 0 015.78 0l2.242 2.242A8.046 8.046 0 0111.55 12.5a7.9 7.9 0 01.46 1.379" />
                    </svg>
                  </div>
                  <div>
                    <p className="font-medium text-text-primary">Modelo de IA</p>
                    <p className="text-xs text-text-secondary">Modelo actual: {aiModel}</p>
                  </div>
                </div>
                <select
                  className="px-3 py-2 bg-dark-input border border-border-default rounded-lg text-text-primary text-sm w-48"
                  value={aiModel}
                  onChange={(e) => setAiModel(e.target.value)}
                >
                  <option value="biomistral-7b-q4">BioMistral 7B Q4</option>
                  <option value="meditron-7b-q4">Meditron 7B Q4</option>
                  <option value="clinicalcamel-7b-q4">ClinicalCamel 7B Q4</option>
                </select>
              </div>
              <div className="flex items-center justify-between mb-4">
                <label className="text-xs font-medium text-text-secondary uppercase tracking-wider">Contexto (tokens)</label>
                <span className="text-clinicalBlue font-mono">{aiContextSize}</span>
              </div>
              <input
                type="range"
                min="512"
                max="8192"
                step="256"
                value={aiContextSize}
                onChange={(e) => setAiContextSize(parseInt(e.target.value))}
                className="w-full h-2 bg-dark-input appearance-none rounded-lg accent-clinicalBlue"
              />
              <div className="flex items-center justify-between">
                <label className="text-xs font-medium text-text-secondary uppercase tracking-wider">Temperatura</label>
                <span className="text-clinicalBlue font-mono">{aiTemperature}</span>
              </div>
              <input
                type="range"
                min="0"
                max="2"
                step="0.1"
                value={aiTemperature}
                onChange={(e) => setAiTemperature(parseFloat(e.target.value))}
                className="w-full h-2 bg-dark-input appearance-none rounded-lg accent-clinicalBlue"
              />
            </div>
          </div>
        </section>

        <section className="mb-8">
          <h2 className="text-xs font-bold text-clinicalBlue uppercase tracking-wider mb-4">ACERCA DE</h2>
          <div className="bg-dark-card rounded-xl border border-border-default overflow-hidden">
            <div className="p-4 border-b border-border-default flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-clinicalBlue/15 flex items-center justify-center">
                  <svg className="w-5 h-5 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.348 0l1.086 3.663a3.002 3.002 0 002.804-.035l3.491-.059a.75.75 0 011.11.33l1.335 2.948a.75.75 0 01-.136 1.086l-3.1 2.265a.75.75 0 01-.672 0l-3.104 2.264a.75.75 0 01-1.121-.176l-1.33-2.95a.75.75 0 00-.21-.83l1.092-3.663a3.02 3.02 0 00-.177-1.569l-1.42.51z" />
                  </svg>
                </div>
                <div>
                  <p className="font-medium text-text-primary">Versión</p>
                  <p className="text-xs text-text-secondary">1.0.0</p>
                </div>
              </div>
              <button className="text-text-secondary hover:text-clinicalBlue text-sm">Restablecer valores</button>
            </div>
            <div className="p-4 border-t border-border-default">
              <button className="text-clinicalBlue hover:underline text-sm flex items-center gap-1">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.348 0l1.086 3.663a3.002 3.002 0 002.804-.035l3.491-.059a.75.75 0 011.11.33l1.335 2.948a.75.75 0 01-.136 1.086l-3.1 2.265a.75.75 0 01-.672 0l-3.104 2.264a.75.75 0 01-1.121-.176l-1.33-2.95a.75.75 0 00-.21-.83l1.092-3.663a3.02 3.02 0 00-.177-1.569l-1.42.51z" />
                </svg>
                Licencias de código abierto
              </button>
            </div>
          </div>
        </section>
      </div>
    </div>
  )
}

export default SettingsPage