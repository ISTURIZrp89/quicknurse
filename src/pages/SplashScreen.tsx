import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthActions } from '@/hooks'

export const SplashScreen = () => {
  const navigate = useNavigate()
  const { checkStatus } = useAuthActions()

  useEffect(() => {
    checkStatus()
  }, [checkStatus, navigate])

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-surface-bg">
      <div className="w-24 h-24 rounded-full bg-clinicalBlue/15 flex items-center justify-center mb-6 animate-pulse">
        <svg 
          className="w-12 h-12 text-clinicalBlue" 
          fill="currentColor" 
          viewBox="0 0 24 24" 
          aria-hidden="true"
        >
          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
        </svg>
      </div>
      <h1 className="text-4xl font-bold text-text-primary tracking-wide mb-2">QuickNurse</h1>
      <p className="text-text-secondary text-lg mb-8">Asistente Clínico Inteligente</p>
      <div className="flex space-x-2">
        {[1, 2, 3].map((i) => (
          <div
            key={i}
            className="w-2 h-2 rounded-full bg-clinicalBlue animate-pulse-soft"
            style={{ animationDelay: `${i * 150}ms` }}
          />
        ))}
      </div>
    </div>
  )
}

export default SplashScreen