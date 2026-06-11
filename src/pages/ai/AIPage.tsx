import { useState, useRef, useEffect, FormEvent, KeyboardEvent } from 'react'
import { useAI } from '../../hooks'

export const AIPage = () => {
  const { isLoading } = useAI()

  const [message, setMessage] = useState('')
  const [conversationHistory, setConversationHistory] = useState<any[]>([])
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [conversationHistory])

  const handleSendMessage = (e?: FormEvent) => {
    if (e) e.preventDefault()
    const text = message.trim()
    if (!text) return
    setConversationHistory(prev => [...prev, { id: Date.now().toString(), role: 'user', content: text, timestamp: new Date().toISOString() }])
    setTimeout(() => {
      setConversationHistory(prev => [...prev, { id: Date.now().toString(), role: 'assistant', content: 'Respuesta simulada para: ' + text, timestamp: new Date().toISOString() }])
    }, 1000)
    setMessage('')
  }

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage()
    }
  }

  return (
    <div className="min-h-screen bg-surface-bg flex flex-col">
      <header className="sticky top-0 z-20 bg-surface-bg/95 backdrop-blur-sm border-b border-border-default">
        <div className="max-w-2xl mx-auto px-screenPadding py-3 flex items-center justify-between">
          <h1 className="text-lg font-bold text-text-primary">Asistente Clínico</h1>
          <div className="flex items-center gap-2">
            <select className="px-2 py-1 bg-surface-input border border-border-default rounded-lg text-sm text-text-primary focus:outline-none focus:ring-1 focus:ring-clinicalBlue">
              <option value="biomistral-7b-q4">BioMistral 7B Q4</option>
              <option value="meditron-7b-q4">Meditron 7B Q4</option>
              <option value="clinicalcamel-7b-q4">ClinicalCamel 7B Q4</option>
            </select>
          </div>
        </div>
      </header>

      <div className="px-screenPadding py-2 border-b border-border-default">
        <div className="overflow-x-auto flex gap-2 pb-2 -mx-screenPadding px-screenPadding">
          <button type="button" className="flex items-center gap-2 px-4 py-2 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary hover:bg-surface-cardHover transition-colors whitespace-nowrap">
            <svg className="w-4 h-4 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414c.39.39.39 1.023 0 1.414l-4 4a2 2 0 01-2.828 0L5 13.172V7a2 2 0 012-2h1.586" />
            </svg>
            <span className="hidden sm:inline">Analizar Medicamento</span>
          </button>
          <button type="button" className="flex items-center gap-2 px-4 py-2 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary hover:bg-surface-cardHover transition-colors whitespace-nowrap">
            <svg className="w-4 h-4 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414c.39.39.39 1.023 0 1.414l-4 4a2 2 0 01-2.828 0L5 13.172V7a2 2 0 012-2h1.586" />
            </svg>
            <span className="hidden sm:inline">Resumen Clínico</span>
          </button>
          <button type="button" className="flex items-center gap-2 px-4 py-2 bg-surface-card border border-border-default rounded-lg text-sm text-text-primary hover:bg-surface-cardHover transition-colors whitespace-nowrap">
            <svg className="w-4 h-4 text-monitorGreen" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 21v-6M12 3v6m0 0v6M3 12h18M12 3v6m0 0v6m0-6h6" />
            </svg>
            <span className="hidden sm:inline">Interpretar Signos</span>
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-screenPadding py-4">
        <div ref={messagesEndRef} className="space-y-4">
          {conversationHistory.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-64 text-center text-text-disabled">
              <div className="w-20 h-20 rounded-full bg-clinicalBlue/10 flex items-center justify-center mb-4">
                <svg className="w-10 h-10 text-clinicalBlue" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9.663 17h4.673M12 3v1m6.364 1.66l-1.21 1.21M21 12h-1.86M21 12l-1.21 1.21M3.342 19.598l1.21-1.21M10.5 4.514a3.136 3.136 0 012.88-1.105l-.023.01zM18 10.414a4.486 4.486 0 01-2.923 5.85M4.493 19.707A6.432 6.432 0 012 14.71a10.97 10.97 0 019.548.528l1.414-1.414a10.971 10.971 0 015.361.885 3.136 3.136 0 01-.163 2.39 15.986 15.986 0 01-3.137 5.114 15.92 15.92 0 01-9.218-4.677z" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-text-primary mt-4">Asistente Clínico IA</h3>
              <p className="text-text-secondary mt-2 max-w-xs mx-auto text-center">
                Realice una consulta clínica o use los accesos rápidos para análisis específicos.
              </p>
            </div>
          ) : (
            conversationHistory.map((msg, index) => (
              <div key={index} className={`flex ${index % 2 === 0 ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[80%] ${index % 2 === 0 ? 'bg-clinicalBlue text-white' : 'bg-surface-card border border-border-default'}`}>
                  <p className="px-4 py-2 text-sm">{msg.content}</p>
                </div>
              </div>
            ))
          )}
        </div>
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSendMessage} className="sticky bottom-0 bg-surface-bg/95 backdrop-blur-sm border-t border-border-default">
        <div className="px-screenPadding py-3">
          <div className="flex items-center gap-2">
            <button type="button" className="p-2 rounded-lg bg-surface-card border border-border-default text-text-secondary hover:bg-surface-cardHover hover:text-text-primary transition-colors" onClick={() => { /* open medication dialog */ }}>
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1a2 2 0 00-2 2H3a2 2 0 00-2 2v1a2 2 0 002 2h18a2 2 0 002-2v-1a2 2 0 00-2-2h-2.5" />
              </svg>
            </button>
            <div className="flex-1 flex items-center gap-2">
              <input
                type="text"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Escribe tu consulta clínica..."
                className="flex-1 px-4 py-3 bg-surface-input border border-border-default rounded-lg text-text-primary placeholder:text-text-disabled focus:outline-none focus:ring-2 focus:ring-clinicalBlue"
              />
              <button
                type="submit"
                disabled={!message.trim() || isLoading}
                className="px-6 py-3 bg-clinicalBlue text-white rounded-lg font-medium disabled:opacity-50 disabled:cursor-not-allowed hover:bg-clinicalBlue/90 active:bg-clinicalBlue transition-colors"
              >
                {isLoading ? 'Enviando...' : 'Enviar'}
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>
  )
}

export default AIPage