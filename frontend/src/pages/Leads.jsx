import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { leadsAPI, usersAPI } from '../api/client'
import { useAuth } from '../context/AuthContext'

const STATUSES = ['', 'new_lead', 'contacted', 'qualified', 'proposal_sent', 'won', 'lost']
const STATUS_LABELS = {
  '': 'All Statuses',
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

export default function Leads() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [assignedFilter, setAssignedFilter] = useState('')
  const [deleteConfirm, setDeleteConfirm] = useState(null)
  const { isAdmin } = useAuth()
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['leads', page, search, statusFilter, assignedFilter],
    queryFn: () =>
      leadsAPI.getAll({
        page,
        per_page: 10,
        search: search || undefined,
        status: statusFilter || undefined,
        assigned_to_id: assignedFilter || undefined,
      }).then((r) => r.data),
  })

  const { data: usersData } = useQuery({
    queryKey: ['users'],
    queryFn: () => usersAPI.getAll().then((r) => r.data),
    enabled: isAdmin,
  })

  const deleteMutation = useMutation({
    mutationFn: (id) => leadsAPI.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['leads'] })
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
      setDeleteConfirm(null)
    },
  })

  const assignMutation = useMutation({
    mutationFn: ({ leadId, userId }) => leadsAPI.assign(leadId, userId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['leads'] }),
  })

  return (
    <div>
      {/* Filters */}
      <div className="bg-white rounded-xl p-4 shadow-sm mb-6">
        <div className="flex flex-col sm:flex-row sm:flex-wrap gap-4 items-center">
          <div className="w-full sm:flex-1 min-w-[250px]">
            <input
              type="text"
              placeholder="Search by name, email, company..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1) }}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none text-sm"
            />
          </div>
          <div className="flex flex-wrap gap-4 sm:gap-2">
            <select
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }}
              className="px-4 py-2 border border-gray-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-indigo-500"
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>{STATUS_LABELS[s]}</option>
              ))}
            </select>
            {isAdmin && (
              <select
                value={assignedFilter}
                onChange={(e) => { setAssignedFilter(e.target.value); setPage(1) }}
                className="px-4 py-2 border border-gray-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">All Assignees</option>
                {usersData?.data?.map((u) => (
                  <option key={u.id} value={u.id}>{u.name}</option>
                ))}
              </select>
            )}
          </div>
        </div>
      </div>

      {/* Leads Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-200">
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Name</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider hidden sm:table-cell">Email</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider hidden md:table-cell">Company</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider hidden lg:table-cell">Assigned To</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider hidden md:table-cell">Date</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="text-center py-12">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto"></div>
                  </td>
                </tr>
              ) : data?.data?.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-gray-400">No leads found</td>
                </tr>
              ) : (
                data?.data?.map((lead) => (
                  <tr key={lead.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3">
                      <Link to={`/leads/${lead.id}`} className="text-sm font-medium text-indigo-600 hover:text-indigo-800">
                        {lead.name}
                      </Link>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 hidden sm:table-cell">{lead.email}</td>
                    <td className="px-4 py-3 text-sm text-gray-600 hidden md:table-cell">{lead.company || '-'}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex px-2.5 py-1 text-xs font-medium rounded-full ${STATUS_COLORS[lead.status] || 'bg-gray-100 text-gray-800'}`}>
                        {STATUS_LABELS[lead.status] || lead.status?.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 hidden lg:table-cell">
                      {lead.assigned_to ? (
                        <div className="flex items-center space-x-2">
                          <span className="font-medium">{lead.assigned_to.name}</span>
                          {isAdmin && (
                            <select
                              value={lead.assigned_to.id}
                              onChange={(e) => assignMutation.mutate({ leadId: lead.id, userId: parseInt(e.target.value) })}
                              className="text-xs border border-gray-200 rounded px-1 py-0.5 bg-gray-50"
                              onClick={(e) => e.stopPropagation()}
                            >
                              <option value="">Unassign</option>
                              {usersData?.data?.map((u) => (
                                <option key={u.id} value={u.id}>{u.name}</option>
                              ))}
                            </select>
                          )}
                        </div>
                      ) : (
                        <span className="text-gray-400">Unassigned</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500 hidden md:table-cell">
                      {new Date(lead.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center space-x-3">
                        <Link
                          to={`/leads/${lead.id}`}
                          className="text-xs font-medium text-indigo-600 hover:text-indigo-800"
                        >
                          View
                        </Link>
                        {isAdmin && (
                          <button
                            onClick={() => setDeleteConfirm(lead.id)}
                            className="text-xs font-medium text-red-600 hover:text-red-800"
                          >
                            Delete
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {data?.meta?.total_pages > 1 && (
          <div className="flex flex-col sm:flex-row items-center justify-between px-4 py-3 bg-white border-t border-gray-200 gap-3">
            <p className="text-sm text-gray-500">
              Page {data.meta.current_page} of {data.meta.total_pages}
            </p>
            <div className="flex space-x-2">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
              >
                Previous
              </button>
              <button
                onClick={() => setPage((p) => p + 1)}
                disabled={page >= (data.meta.total_pages || 1)}
                className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {deleteConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 shadow-xl max-w-sm w-full mx-4">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Delete Lead</h3>
            <p className="text-sm text-gray-600 mb-6">Are you sure you want to delete this lead? This action cannot be undone.</p>
            <div className="flex space-x-3">
              <button
                onClick={() => setDeleteConfirm(null)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition"
              >
                Cancel
              </button>
              <button
                onClick={() => deleteMutation.mutate(deleteConfirm)}
                className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700 transition"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
