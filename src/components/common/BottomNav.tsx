import React from 'react'
import { NavLink } from 'react-router-dom'
import { Brain, Calculator, Users, Calendar, Settings } from 'lucide-react'

const BottomNav: React.FC = () => {
  const items = [
    { to: '/ai', label: 'Asistente', icon: Brain },
    { to: '/calculators', label: 'Calculadoras', icon: Calculator },
    { to: '/patients', label: 'Pacientes', icon: Users },
    { to: '/shifts', label: 'Turnos', icon: Calendar },
    { to: '/settings', label: 'Ajustes', icon: Settings },
  ]
  return (
    <nav className="fixed bottom-0 inset-x-0 z-20 bg-dark-bg/90 backdrop-blur-md border-t border-border-default safe-bottom">
      <div className="max-w-2xl mx-auto grid grid-cols-5">
        {items.map((it) => (
          <NavLink
            key={it.to}
            to={it.to}
            className={({ isActive }) =>
              `flex flex-col items-center justify-center py-2 text-[11px] transition-colors ${
                isActive ? 'text-clinicalBlue' : 'text-text-secondary'
              }`
            }
          >
            <it.icon className="w-6 h-6 mb-1" />
            {it.label}
          </NavLink>
        ))}
      </div>
    </nav>
  )
}

export default BottomNav
