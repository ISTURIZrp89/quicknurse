export const HomePage = () => {
  const quickActions = [
    {
      icon: '💊',
      label: 'Analizar Medicamento',
      action: () => { /* TODO */ },
      color: 'bg-clinicalBlue/10 text-clinicalBlue border-clinicalBlue/20',
    },
    {
      icon: '📋',
      label: 'Resumen Clínico (SOAP)',
      action: () => { /* TODO */ },
      color: 'bg-monitorGreen/10 text-monitorGreen border-monitorGreen/20',
    },
    {
      icon: '💓',
      label: 'Interpretar Signos Vitales',
      action: () => { /* TODO */ },
      color: 'bg-alertRed/10 text-alertRed border-alertRed/20',
    },
    {
      icon: '🏥',
      label: 'Diagnóstico NANDA',
      action: () => { /* TODO */ },
      color: 'bg-amber-500/10 text-amber-500 border-amber-500/20',
    },
  ]

  return (
    <div className="min-h-screen bg-deepBlack">
      <header className="sticky top-0 z-10 bg-dark-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-4 flex items-center justify-between">
          <h1 className="text-xl font-bold text-text-primary">QuickNurse</h1>
          <button className="p-2 rounded-lg bg-dark-card hover:bg-dark-cardHover transition-colors">
            <svg className="w-6 h-6 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.348 0l1.086 3.663a3.002 3.002 0 002.804-.035l3.491-.059a.75.75 0 011.11.33l1.335 2.948a.75.75 0 01-.136 1.086l-3.1 2.265a.75.75 0 01-.672 0l-3.104 2.264a.75.75 0 01-1.121-.176l-1.33-2.95a.75.75 0 00-.21-.83l1.092-3.663a3.02 3.02 0 00-.177-1.569l-1.42.51z" />
            </svg>
          </button>
        </div>
      </header>

      <main className="max-w-2xl mx-auto p-screenPadding pb-20">
        <section className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-clinicalBlue to-monitorGreen flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              </svg>
            </div>
            <div>
              <h1 className="text-xl font-bold text-text-primary">Bienvenido</h1>
              <p className="text-sm text-text-secondary">Listo para tu turno</p>
            </div>
          </div>
        </section>

        <section className="mb-8">
          <h2 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-4">Accesos rápidos</h2>
          <div className="grid grid-cols-2 gap-3">
            {quickActions.map((action, index) => (
              <button
                key={index}
                onClick={action.action}
                className={`flex items-center gap-3 p-4 rounded-xl border ${action.color} hover:bg-opacity-20 transition-all duration-200 active:scale-[0.98]`}
              >
                <span className="text-2xl">{action.icon}</span>
                <span className="font-medium text-text-primary">{action.label}</span>
              </button>
            ))}
          </div>
        </section>

        <section className="mb-8">
          <div className="grid grid-cols-3 gap-3">
            <div className="bg-dark-card rounded-xl border border-border-default p-4">
              <p className="text-xs text-text-secondary uppercase tracking-wider mb-1">Calculadoras</p>
              <p className="text-2xl font-bold text-clinicalBlue">19</p>
            </div>
            <div className="bg-dark-card rounded-xl border border-border-default p-4">
              <p className="text-xs text-text-secondary uppercase tracking-wider mb-1">Pacientes</p>
              <p className="text-2xl font-bold text-monitorGreen">0</p>
            </div>
            <div className="bg-dark-card rounded-xl border border-border-default p-4">
              <p className="text-xs text-text-secondary uppercase tracking-wider mb-1">Turnos</p>
              <p className="text-2xl font-bold text-alertRed">0</p>
            </div>
          </div>
        </section>

        <section>
          <h3 className="text-sm font-bold text-clinicalBlue uppercase tracking-wider mb-4">Actividad reciente</h3>
          <div className="bg-dark-card rounded-xl border border-border-default overflow-hidden">
            <div className="p-4 border-b border-border-default flex items-center justify-between">
              <h3 className="font-medium text-text-primary">Sin actividad reciente</h3>
              <span className="text-xs text-text-secondary">Empieza a usar QuickNurse</span>
            </div>
            <div className="p-4 text-center text-text-secondary text-sm">
              Tus cálculos, pacientes y conversaciones aparecerán aquí
            </div>
          </div>
        </section>
      </main>
    </div>
  )
}

export default HomePage