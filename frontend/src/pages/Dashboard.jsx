import { useQuery } from '@tanstack/react-query'
import { dashboardAPI } from '../api/client'

const CARDS = [
  { key: 'total_leads', label: 'Total Leads', bg: 'bg-blue-50', icon: '📋' },
  { key: 'new_leads', label: 'New Leads', bg: 'bg-green-50', icon: '🆕' },
  { key: 'contacted', label: 'Contacted', bg: 'bg-yellow-50', icon: '📞' },
  { key: 'qualified', label: 'Qualified', bg: 'bg-purple-50', icon: '⭐' },
  { key: 'proposal_sent', label: 'Proposal Sent', bg: 'bg-indigo-50', icon: '📄' },
  { key: 'won', label: 'Won', bg: 'bg-emerald-50', icon: '🏆' },
  { key: 'lost', label: 'Lost', bg: 'bg-red-50', icon: '❌' },
]

export default function Dashboard() {
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => dashboardAPI.getStats().then((r) => r.data),
    refetchInterval: 30000,
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  return (
    <div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {CARDS.map((card) => (
          <div key={card.key} className={card.bg + ' rounded-xl p-6 shadow-sm hover:shadow-md transition-colors'}>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium opacity-75">{card.label}</p>
                <p className="text-3xl font-bold mt-1 text-gray-800">
                  {data ? data[card.key] || 0 : 0}
                </p>
              </div>
              <span className="text-3xl">{card.icon}</span>
            </div>
          </div>
        ))}
      </div>
      {data && data.total_leads > 0 && (
        <div className="mt-8 bg-white rounded-xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Lead Breakdown</h2>
          <div className="space-y-3">
            {CARDS.filter(c => c.key !== 'total_leads').map((card) => {
              const value = data[card.key] || 0
              const pct = data.total_leads > 0 ? (value / data.total_leads) * 100 : 0
              const barColor = 'bg-' + card.bg.replace('bg-', '').replace('50', '500')
              return (
                <div key={card.key} className="flex items-center">
                  <span className="w-24 sm:w-32 text-sm text-gray-600 truncate">{card.icon} {card.label}</span>
                  <div className="flex-1 mx-2 sm:mx-4">
                    <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                      <div className={'h-full rounded-full transition-all duration-500 ' + barColor} style={{ width: pct + '%' }} />
                    </div>
                  </div>
                  <span className="text-sm font-medium text-gray-700 w-8 sm:w-12 text-right">{value}</span>
                </div>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}
