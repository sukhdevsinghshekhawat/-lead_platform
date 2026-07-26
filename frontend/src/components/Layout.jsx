import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const navItems = [
  { path: '/dashboard', label: 'Dashboard', icon: 'D' },
  { path: '/leads', label: 'Leads', icon: 'L' },
]

export default function Layout({ children }) {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const { user, logout } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      <aside className={(sidebarOpen ? 'w-64' : 'w-20') + ' bg-white border-r border-gray-200 transition-all duration-300 flex flex-col'}>
        <div className="h-16 flex items-center px-4 border-b border-gray-200">
          <button onClick={() => setSidebarOpen(!sidebarOpen)} className="text-gray-500 hover:text-gray-700">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          {sidebarOpen && <span className="ml-3 font-bold text-gray-800 text-lg">LeadManager</span>}
        </div>
        <nav className="flex-1 py-4 space-y-1">
          {navItems.map((item) => {
            const isActive = location.pathname === item.path
            return (
              <Link key={item.path} to={item.path} className={'flex items-center px-4 py-3 text-sm font-medium ' + (isActive ? 'bg-indigo-50 text-indigo-700 border-r-2 border-indigo-600' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-800')}>
                <span className={(sidebarOpen ? 'mr-3' : 'mx-auto') + ' flex items-center justify-center w-8 h-8 rounded-lg bg-gray-100 text-sm font-bold'}>
                  {item.icon}
                </span>
                {sidebarOpen && <span>{item.label}</span>}
              </Link>
            )
          })}
        </nav>
      </aside>
      <div className="flex-1 flex flex-col">
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-end px-6 shadow-sm">
          <div className="flex items-center space-x-4">
            <div className="text-right">
              <p className="text-sm font-medium text-gray-700">{user?.name}</p>
              <p className="text-xs text-gray-500 capitalize">{user?.role}</p>
            </div>
            <div className="h-9 w-9 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold text-sm">
              {user?.name?.charAt(0)?.toUpperCase() || 'U'}
            </div>
            <button onClick={handleLogout} className="text-sm text-gray-500 hover:text-red-600 transition font-medium">
              Logout
            </button>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
    )
}
