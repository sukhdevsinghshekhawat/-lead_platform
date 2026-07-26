import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { leadsAPI, usersAPI } from '../api/client'
import { useAuth } from '../context/AuthContext'

const STATUSES = ['new_lead', 'contacted', 'qualified', 'proposal_sent', 'won', 'lost']
const STATUS_LABELS = {
  new_lead: 'New',
  contacted: 'Contacted',
  qualified: 'Qualified',
  proposal_sent: 'Proposal Sent',
  won: 'Won',
  lost: 'Lost',
}
const STATUS_COLORS = {
  new_lead: 'bg-blue-100 text-blue-800',
  contacted: 'bg-yellow-100 text-yellow-800',
  qualified: 'bg-purple-100 text-purple-800',
  proposal_sent: 'bg-indigo-100 text-indigo-800',
  won: 'bg-emerald-100 text-emerald-800',
  lost: 'bg-red-100 text-red-800',
}

export default function LeadDetails() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { isAdmin } = useAuth()
  const queryClient = useQueryClient()
  const [noteMessage, setNoteMessage] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['lead', id],
    queryFn: () => leadsAPI.getOne(id).then((r) => r.data),
  })

  const { data: usersData } = useQuery({
    queryKey: ['users'],
    queryFn: () => usersAPI.getAll().then((r) => r.data),
    enabled: isAdmin,
  })

  const statusMutation = useMutation({
    mutationFn: (status) => leadsAPI.updateStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lead', id] })
      queryClient.invalidateQueries({ queryKey: ['leads'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
    },
  })

  const assignMutation = useMutation({
    mutationFn: (userId) => leadsAPI.assign(id, userId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lead', id] })
      queryClient.invalidateQueries({ queryKey: ['leads'] })
    },
  })

  const noteMutation = useMutation({
    mutationFn: (message) => leadsAPI.addNote(id, message),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lead', id] })
      setNoteMessage('')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: () => leadsAPI.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['leads'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
      navigate('/leads')
    },
  })

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Lead not found</p>
      </div>
    )
  }

  const { lead, notes, activities } = data
  const currentStatusLabel = STATUS_LABELS[lead.status] || lead.status

  return (
    <div className="space-y-6 max-w-5xl mx-auto">
      {/* Lead Header */}
      <div className="bg-white rounded-xl p-6 shadow-sm">
        <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-2xl font-bold text-gray-900">{lead.name}</h1>
              <span className={`inline-flex px-2.5 py-1 text-xs font-medium rounded-full ${STATUS_COLORS[lead.status] || 'bg-gray-100 text-gray-800'}`}>
                {currentStatusLabel}
              </span>
            </div>
            <p className="text-gray-500 mt-1">{lead.email}</p>
          </div>
          <div className="flex items-center space-x-3">
            <select
              value={lead.status}
              onChange={(e) => statusMutation.mutate(e.target.value)}
              className="px-3 py-2 text-sm border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-indigo-500"
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>{STATUS_LABELS[s]}</option>
              ))}
            </select>
            {isAdmin && (
              <button
                onClick={() => {
                  if (window.confirm('Delete this lead permanently?')) {
                    deleteMutation.mutate()
                  }
                }}
                className="px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition font-medium"
              >
                Delete
              </button>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-6 p-4 bg-gray-50 rounded-lg">
          <div>
            <p className="text-xs text-gray-500 uppercase font-semibold tracking-wider">Phone</p>
            <p className="text-sm text-gray-800 mt-1">{lead.phone || '-'}</p>
          </div>
          <div>
            <p className="text-xs text-gray-500 uppercase font-semibold tracking-wider">Company</p>
            <p className="text-sm text-gray-800 mt-1">{lead.company || '-'}</p>
          </div>
          <div>
            <p className="text-xs text-gray-500 uppercase font-semibold tracking-wider">Assigned To</p>
            {isAdmin ? (
              <select
                value={lead.assigned_to?.id || ''}
                onChange={(e) => {
                  const val = e.target.value
                  if (val) assignMutation.mutate(parseInt(val))
                }}
                className="mt-1 text-sm border border-gray-200 rounded px-2 py-1 bg-white"
              >
                <option value="">Unassigned</option>
                {usersData?.data?.map((u) => (
                  <option key={u.id} value={u.id}>{u.name}</option>
                ))}
              </select>
            ) : (
              <p className="text-sm text-gray-800 mt-1 font-medium">
                {lead.assigned_to?.name || 'Unassigned'}
              </p>
            )}
          </div>
        </div>

        {lead.message && (
          <div className="mt-4">
            <p className="text-xs text-gray-500 uppercase font-semibold tracking-wider mb-1">Message</p>
            <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded-lg">{lead.message}</p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Notes Section */}
        <div className="bg-white rounded-xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Notes</h2>

          <div className="space-y-3 mb-4 max-h-96 overflow-y-auto">
            {notes?.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">No notes yet</p>
            ) : (
              notes?.map((note) => (
                <div key={note.id} className="p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-semibold text-gray-700">{note.user?.name || 'Unknown'}</p>
                    <p className="text-xs text-gray-400">{new Date(note.created_at).toLocaleString()}</p>
                  </div>
                  <p className="text-sm text-gray-600">{note.message}</p>
                </div>
              )).reverse()
            )}
          </div>

          <div className="flex space-x-2">
            <input
              type="text"
              value={noteMessage}
              onChange={(e) => setNoteMessage(e.target.value)}
              placeholder="Add a note..."
              className="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-indigo-500"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && noteMessage.trim()) {
                  noteMutation.mutate(noteMessage.trim())
                }
              }}
            />
            <button
              onClick={() => noteMutation.mutate(noteMessage.trim())}
              disabled={!noteMessage.trim() || noteMutation.isPending}
              className="px-4 py-2 bg-indigo-600 text-white text-sm rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition font-medium"
            >
              {noteMutation.isPending ? '...' : 'Add'}
            </button>
          </div>
        </div>

        {/* Activity Timeline */}
        <div className="bg-white rounded-xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-800 mb-4">Activity Timeline</h2>

          <div className="space-y-4 max-h-96 overflow-y-auto">
            {activities?.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">No activity yet</p>
            ) : (
              activities?.map((activity) => {
                const iconMap = {
                  lead_created: '📝',
                  lead_assigned: '👤',
                  status_changed: '🔄',
                  note_added: '💬',
                }
                return (
                  <div key={activity.id} className="flex items-start space-x-3">
                    <div className="flex-shrink-0 w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center text-sm">
                      {iconMap[activity.action] || '📌'}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-gray-800">
                        <span className="font-medium">{activity.user?.name || 'System'}</span>
                        {' '}
                        <span className="text-gray-600">{activity.details || activity.action}</span>
                      </p>
                      <p className="text-xs text-gray-400 mt-0.5">
                        {new Date(activity.created_at).toLocaleString()}
                      </p>
                    </div>
                  </div>
                )
              }).reverse()
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
