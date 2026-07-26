import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || '/api'

const client = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

client.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      if (window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export const authAPI = {
  login: (email, password) => client.post('/login', { email, password }),
  me: () => client.get('/me'),
}

export const leadsAPI = {
  getAll: (params) => client.get('/leads', { params }),
  getOne: (id) => client.get(`/leads/${id}`),
  create: (data) => client.post('/leads', data),
  update: (id, data) => client.patch(`/leads/${id}`, data),
  delete: (id) => client.delete(`/leads/${id}`),
  updateStatus: (id, status) => client.patch(`/leads/${id}/update_status`, { status }),
  assign: (id, assignedToId) => client.patch(`/leads/${id}/assign`, { assigned_to_id: assignedToId }),
  addNote: (id, message) => client.post(`/leads/${id}/add_note`, { message }),
}

export const usersAPI = {
  getAll: () => client.get('/users'),
  create: (data) => client.post('/users', data),
  delete: (id) => client.delete(`/users/${id}`),
}

export const dashboardAPI = {
  getStats: () => client.get('/dashboard'),
}

export default client
