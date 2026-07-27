import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const navItems = [
  { path: '/dashboard', label: 'Dashboard', icon: 'D' },
  { path: '/leads', label: 'Leads', icon: 'L' },
]

export default function Layout({ children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const { user, logout } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const sidebarWidth = sidebarCollapsed ? 'w-20' : 'w-64'

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Mobile Overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar - hidden on mobile, visible on desktop */}
      <aside
        className={
          'fixed md:relative z-50 md:z-auto ' +
          'h-screen bg-white border-r border-gray-200 transition-all duration-300 flex flex-col ' +
          (sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0') +
          ' ' +
          sidebarWidth
        }
      >
        <div className="h-16 flex items-center px-4 border-b border-gray-200">
          <button
            onClick={() => {
              if (window.innerWidth < 768) {
                setSidebarOpen(false)
              } else {
                setSidebarCollapsed(!sidebarCollapsed)
              }
            }}
            className="text-gray-500 hover:text-gray-700"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          {sidebarCollapsed ? null : (
            <span className="ml-3 font-bold text-gray-800 text-lg">LeadManager</span>
          )}
        </div>
        <nav className="flex-1 py-4 space-y-1">
          {navItems.map((item) => {
            const isActive = location.pathname === item.path
            return (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => {
                  if (window.innerWidth < 768) {
                    setSidebarOpen(false)
                  }
                }}
                className={
                  'flex items-center px-4 py-3 text-sm font-medium ' +
                  (isActive
                    ? 'bg-indigo-50 text-indigo-700 border-r-2 border-indigo-600'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-800')
                }
              >
                <span
                  className={
                    (sidebarCollapsed ? 'mx-auto' : 'mr-3') +
                    ' flex items-center justify-center w-8 h-8 rounded-lg bg-gray-100 text-sm font-bold'
                  }
                >
                  {item.icon}
                </span>
                {!sidebarCollapsed && <span>{item.label}</span>}
              </Link>
            )
          })}
        </nav>
      </aside>

      <div className="flex-1 flex flex-col">
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-4 sm:px-6 shadow-sm">
          <div className="flex items-center">
            <button
              onClick={() => setSidebarOpen(true)}
              className="md:hidden text-gray-500 hover:text-gray-700 mr-2"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
            <h1 className="text-lg font-semibold text-gray-800 hidden sm:block">
              {navItems.find((n) => n.path === location.pathname)?.label || 'Dashboard'}
            </h1>
          </div>
          <div className="flex items-center space-x-4">
            <div className="text-right">
              <p className="text-sm font-medium text-gray-700">{user?.name}</p>
              <p className="text-xs text-gray-500 capitalize">{user?.role}</p>
            </div>
            <div className="h-9 w-9 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold text-sm">
              {user?.name?.charAt(0)?.toUpperCase() || 'U'}
            </div>
            <button
              onClick={handleLogout}
              className="text-sm text-gray-500 hover:text-red-600 transition font-medium"
            >
              Logout
            </button>
          </div>
        </header>
        <main className="flex-1 p-4 sm:p-6 overflow-auto">{children}</main>
        <footer className="text-center py-3 text-xs text-gray-500 border-t border-gray-200">
          <a
            href="https://digitalheroesco.com"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-indigo-600 transition font-medium"
          >
            Built for Digital Heroes Training Task By Sukhdev Singh
          </a>
        </footer>
      </div>
    </div>
  )
}
