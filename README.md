# LeadManager CRM

A production-ready Lead Management Application built with Ruby on Rails 8 (API-only) and React 19.

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Role Permissions Matrix](#role-permissions-matrix)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Database Schema](#database-schema)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Demo Credentials](#demo-credentials)
- [Assignment Requirement Verification](#assignment-requirement-verification)
- [Live Build Requirement](#live-build-requirement)
- [License](#license)

## Overview

LeadManager CRM is a full-featured lead management system designed for small sales teams. It provides public lead capture, JWT-based authentication, role-based authorization (Admin/Member), lead lifecycle management, notes, activity timeline, and a professional dashboard.

## Authentication

### JWT Authentication Flow

The application uses **JSON Web Tokens (JWT)** for stateless authentication.

1. **Login**: User sends `POST /api/login` with email and password.
2. **Token Issuance**: Server validates credentials, generates a JWT (24-hour expiry) containing the user ID, and returns it in the response.
3. **Token Storage**: The frontend stores the token in `localStorage`.
4. **Authenticated Requests**: The frontend attaches the token as `Authorization: Bearer <token>` header on every API request via Axios interceptor.
5. **Token Verification**: The server's `ApplicationController#authenticate_request` decodes the token, looks up the user, and sets `@current_user`. If invalid/expired, returns `401 Unauthorized`.
6. **Logout**: The frontend removes the token from `localStorage`; no server-side logout is needed.

### Authorization Middleware

- **Pundit** handles authorization at the controller level via `authorize @lead`.
- **`ApplicationPolicy`** provides base rules. **`LeadPolicy`** defines action-specific permissions (admin vs member, assigned vs unassigned).
- **`require_admin!`** is used in controllers for admin-only endpoints (user management).
- **`policy_scope`** scopes queries so members only see their assigned leads.

### Protected Routes

- Protected API routes call `before_action :authenticate_request`.
- Frontend uses `<ProtectedRoute>` component to redirect unauthenticated users to `/login`.

## Role Permissions Matrix

| Feature | Admin | Member (Assigned Lead) | Member (Unassigned Lead) |
|---|---|---|---|
| View Leads List | ✅ All leads | ✅ Assigned only | ✅ Assigned only |
| View Lead Details | ✅ | ✅ | ❌ |
| Create Lead | ✅ (via API + form) | ✅ (via API + public form) | ✅ (via public form) |
| Edit Lead | ✅ | ✅ | ❌ |
| Delete Lead | ✅ | ❌ | ❌ |
| Assign Lead | ✅ | ❌ | ❌ |
| Change Lead Status | ✅ | ✅ | ❌ |
| Add Notes | ✅ | ✅ | ❌ |
| Manage Users | ✅ | ❌ | ❌ |

## Features

- **Public Lead Capture Form** — Anyone can submit leads without authentication
- **JWT Authentication** — Secure token-based login/logout
- **Role-Based Authorization** — Admin (full access) and Member (assigned leads only)
- **Lead Lifecycle** — 6 statuses: New, Contacted, Qualified, Proposal Sent, Won, Lost
- **Lead Assignment** — Admin can assign leads to team members
- **Notes** — Each lead supports notes with user, message, and timestamp
- **Activity Timeline** — Complete audit trail (lead created, assigned, status changed, note added)
- **Dashboard** — Summary cards with lead counts by status
- **Leads Table** — Search, pagination, filter by status and assigned user
- **Responsive UI** — Professional CRM dashboard with Tailwind CSS

## Tech Stack

### Backend
- **Ruby on Rails 8** (API Only)
- **PostgreSQL** (SQLite for development)
- **JWT** (jsonwebtoken)
- **bcrypt** (has_secure_password)
- **Pundit** (role-based authorization)
- **Kaminari** (pagination)
- **RSpec** (testing)

### Frontend
- **React 19**
- **Vite** (build tool)
- **Tailwind CSS** (styling)
- **React Router** (routing)
- **Axios** (HTTP client)
- **React Query** (data fetching)

## Project Structure

### Backend (Rails)
```
backend/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb       # Base controller with JWT auth
│   │   └── api/
│   │       ├── auth_controller.rb          # Login, logout, me
│   │       ├── dashboard_controller.rb     # Dashboard stats
│   │       ├── leads_controller.rb         # Lead CRUD, status, assign, notes
│   │       └── users_controller.rb         # User management (admin only)
│   ├── models/
│   │   ├── user.rb                         # User with role enum
│   │   ├── lead.rb                         # Lead with status enum, scopes
│   │   ├── note.rb                         # Note model
│   │   └── activity.rb                     # Activity model
│   ├── policies/
│   │   ├── application_policy.rb           # Base policy
│   │   └── lead_policy.rb                  # Lead authorization rules
│   ├── serializers/
│   │   ├── lead_serializer.rb
│   │   ├── note_serializer.rb
│   │   ├── activity_serializer.rb
│   │   └── user_serializer.rb
│   └── services/
│       ├── jwt_service.rb                  # JWT encode/decode
│       └── activity_service.rb             # Activity tracking
├── config/
│   ├── routes.rb                           # API routes
│   └── database.yml                        # Database config
├── db/
│   ├── migrate/                            # Database migrations
│   ├── schema.rb                           # Database schema
│   └── seeds.rb                            # Seed data
└── spec/                                   # RSpec tests
    ├── factories/                          # FactoryBot factories
    ├── models/                             # Model specs
    ├── requests/                           # Request specs
    └── policies/                           # Policy specs
```

### Frontend (React)
```
frontend/
├── src/
│   ├── api/
│   │   └── client.js                       # Axios client with JWT interceptor
│   ├── components/
│   │   ├── Layout.jsx                      # Sidebar + Navbar layout
│   │   └── ProtectedRoute.jsx              # Auth guard
│   ├── context/
│   │   └── AuthContext.jsx                 # Auth state management
│   ├── pages/
│   │   ├── Login.jsx                       # Login page
│   │   ├── Dashboard.jsx                   # Dashboard with stats cards
│   │   ├── Leads.jsx                       # Leads table with search/filter
│   │   ├── LeadDetails.jsx                 # Lead details + notes
│   │   └── PublicLeadForm.jsx              # Public lead capture form
│   ├── App.jsx                             # Routes
│   └── main.jsx                            # Entry point
├── index.html
└── vite.config.js
```

## Installation

### Prerequisites
- Ruby 3.3+
- Node.js 20+
- PostgreSQL (for production)

### Backend Setup

```bash
cd backend
bundle install
rails db:create
rails db:migrate
rails db:seed
rails server -p 3000
```

### Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:5173` and the backend at `http://localhost:3000`.

## Environment Variables

### Backend (`.env` or environment variables)

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `sqlite3://db/development.sqlite3` |
| `JWT_SECRET` | Secret key for JWT signing | `rails_credentials` |
| `RAILS_ENV` | Rails environment | `development` |

### Frontend (`.env`)

| Variable | Description | Default |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API URL | `http://localhost:3000` |

## Database Schema

### Users
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | string | User name |
| `email` | string | Unique email |
| `password_digest` | string | bcrypt hash |
| `role` | integer | 0=member, 1=admin |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**Indexes:** `index_users_on_email` (unique)

### Leads
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `name` | string | Lead name |
| `email` | string | Lead email |
| `phone` | string | Lead phone |
| `company` | string | Company name |
| `message` | text | Inquiry message |
| `status` | integer | 0=new, 1=contacted, 2=qualified, 3=proposal_sent, 4=won, 5=lost |
| `assigned_to_id` | bigint | Foreign key to users |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**Foreign Keys:** `assigned_to_id` references `users(id)`
**Indexes:** `index_leads_on_assigned_to_id`, `index_leads_on_created_at`, `index_leads_on_email`, `index_leads_on_status`

### Notes
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `lead_id` | bigint | Foreign key to leads |
| `user_id` | bigint | Foreign key to users |
| `message` | text | Note content |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**Foreign Keys:** `lead_id` references `leads(id)`, `user_id` references `users(id)`
**Indexes:** `index_notes_on_lead_id`, `index_notes_on_user_id`

### Activities
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `lead_id` | bigint | Foreign key to leads |
| `user_id` | bigint | Foreign key to users (nullable) |
| `action` | string | lead_created, lead_assigned, status_changed, note_added |
| `details` | text | Human-readable description |
| `created_at` | datetime | |

**Foreign Keys:** `lead_id` references `leads(id)`, `user_id` references `users(id)`
**Indexes:** `index_activities_on_lead_id`, `index_activities_on_user_id`

### Relationships (ER Diagram)

```
User (1) ──────< Lead (assigned_to)  : A user can be assigned many leads
User (1) ──────< Note                 : A user can write many notes
User (1) ──────< Activity             : A user can perform many activities
Lead  (1) ──────< Note                : A lead can have many notes
Lead  (1) ──────< Activity            : A lead can have many activities
```

### Lead Lifecycle

The `status` column tracks the lead through a defined sales pipeline:

```
New → Contacted → Qualified → Proposal Sent → Won
  ↘
   Lost
```

- **New**: Lead just submitted via public form or created manually
- **Contacted**: Initial outreach made
- **Qualified**: Lead meets criteria and is a potential customer
- **Proposal Sent**: Formal proposal/quote sent to the lead
- **Won**: Lead converted to a customer
- **Lost**: Lead did not convert (can end at any stage)

All status transitions are recorded in the `activities` table for a complete audit trail.

## API Documentation

All endpoints return JSON. Authenticated endpoints require `Authorization: Bearer <token>` header.

### Authentication

#### POST /api/login
Login with email and password.

**Authentication:** None required

**Request:**
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin",
    "role_label": "Admin"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid email or password
  ```json
  { "error": "Invalid email or password" }
  ```

#### GET /api/me
Get current authenticated user.

**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin",
    "role_label": "Admin"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```

#### GET /api/leads
List leads with pagination, search, and filtering.

**Authentication:** Required (Bearer token)

**Query Parameters:**
- `page` (default: 1)
- `per_page` (default: 10)
- `search` (optional: searches name, email, company, phone)
- `status` (optional: new_lead, contacted, qualified, proposal_sent, won, lost)
- `assigned_to_id` (optional)

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Sarah Connor",
      "email": "sarah@example.com",
      "phone": "+1-555-0101",
      "company": "TechCorp",
      "message": "Interested in enterprise plan",
      "status": "new_lead",
      "status_label": "New lead",
      "assigned_to": { "id": 2, "name": "Alice Johnson", "email": "member1@example.com" },
      "created_at": "2026-07-26T05:08:11.581Z",
      "updated_at": "2026-07-26T05:08:11.581Z",
      "notes_count": 2,
      "activities_count": 4
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25,
    "per_page": 10
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```

#### GET /api/leads/:id
Get lead details with notes and activities.

**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "lead": { ... },
  "notes": [ ... ],
  "activities": [ ... ]
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `404 Not Found`: Lead does not exist
  ```json
  { "error": "Lead not found" }
  ```
- `403 Forbidden`: Not authorized to view this lead
  ```json
  { "error": "Forbidden" }
  ```

#### POST /api/leads
Create a new lead (public, no authentication required).

**Authentication:** None required (public)

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1-555-0000",
  "company": "Acme Inc.",
  "message": "Interested in your services"
}
```

**Success Response (201):**
```json
{
  "data": { ... }
}
```

**Error Responses:**
- `422 Unprocessable Entity`: Validation failed
  ```json
  { "errors": ["Name can't be blank", "Email is invalid"] }
  ```

#### PATCH /api/leads/:id
Update lead details (admin or assigned member).

**Authentication:** Required (Bearer token)

**Request:**
```json
{
  "name": "Updated Name",
  "company": "New Company"
}
```

**Success Response (200):**
```json
{
  "data": { ... }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not authorized to update this lead
  ```json
  { "error": "Forbidden" }
  ```
- `404 Not Found`: Lead does not exist
  ```json
  { "error": "Lead not found" }
  ```
- `422 Unprocessable Entity`: Validation failed
  ```json
  { "errors": ["Name can't be blank"] }
  ```

#### DELETE /api/leads/:id
Delete a lead (admin only).

**Authentication:** Required (Bearer token)

**Success Response (204):** No content

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not authorized to delete this lead (member)
  ```json
  { "error": "Forbidden" }
  ```
- `404 Not Found`: Lead does not exist
  ```json
  { "error": "Lead not found" }
  ```

#### PATCH /api/leads/:id/update_status
Update lead status (admin or assigned member).

**Authentication:** Required (Bearer token)

**Request:**
```json
{
  "status": "contacted"
}
```

**Success Response (200):**
```json
{
  "data": { ... }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not authorized to change status
  ```json
  { "error": "Forbidden" }
  ```
- `404 Not Found`: Lead does not exist
  ```json
  { "error": "Lead not found" }
  ```
- `422 Unprocessable Entity`: Invalid status value
  ```json
  { "errors": ["Status is not included in the list"] }
  ```

#### PATCH /api/leads/:id/assign
Assign lead to a user (admin only).

**Authentication:** Required (Bearer token)

**Request:**
```json
{
  "assigned_to_id": 2
}
```

**Success Response (200):**
```json
{
  "data": { ... }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not authorized to assign leads (member)
  ```json
  { "error": "Forbidden" }
  ```
- `404 Not Found`: Lead or target user does not exist
  ```json
  { "error": "User not found" }
  ```

#### POST /api/leads/:id/add_note
Add a note to a lead (admin or assigned member).

**Authentication:** Required (Bearer token)

**Request:**
```json
{
  "message": "Called the customer, left a voicemail"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": 5,
    "message": "Called the customer, left a voicemail",
    "user": { "id": 1, "name": "Admin User", "email": "admin@example.com" },
    "created_at": "2026-07-26T17:18:30.914Z",
    "updated_at": "2026-07-26T17:18:30.914Z"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not authorized to add notes
  ```json
  { "error": "Forbidden" }
  ```
- `404 Not Found`: Lead does not exist
  ```json
  { "error": "Lead not found" }
  ```
- `422 Unprocessable Entity`: Note message blank
  ```json
  { "errors": ["Message can't be blank"] }
  ```

### Users

#### GET /api/users
List all users (admin or any authenticated user).

**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@example.com",
      "role": "admin",
      "role_label": "Admin",
      "created_at": "2026-07-26T05:08:11.581Z"
    }
  ]
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```

#### POST /api/users
Create a new user (admin only).

**Authentication:** Required (Bearer token, admin role)

**Request:**
```json
{
  "name": "New User",
  "email": "new@example.com",
  "password": "password123",
  "role": "member"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": 3,
    "name": "New User",
    "email": "new@example.com",
    "role": "member",
    "role_label": "Member"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not admin
  ```json
  { "error": "Forbidden" }
  ```
- `422 Unprocessable Entity`: Validation failed
  ```json
  { "errors": ["Email has already been taken"] }
  ```

#### DELETE /api/users/:id
Delete a user (admin only).

**Authentication:** Required (Bearer token, admin role)

**Success Response (204):** No content

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```
- `403 Forbidden`: Not admin
  ```json
  { "error": "Forbidden" }
  ```

### Dashboard

#### GET /api/dashboard
Get dashboard statistics.

**Authentication:** Required (Bearer token)

**Success Response (200):**
```json
{
  "total_leads": 25,
  "new_leads": 5,
  "contacted": 3,
  "qualified": 2,
  "proposal_sent": 1,
  "won": 8,
  "lost": 6
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
  ```json
  { "error": "Unauthorized" }
  ```

## Testing

### Backend Tests

```bash
cd backend
bundle exec rspec                          # Run all tests
bundle exec rspec spec/models/             # Model tests
bundle exec rspec spec/requests/           # Request tests
bundle exec rspec spec/policies/           # Policy tests
bundle exec rspec --format documentation   # Detailed output
```

### Test Coverage

#### Backend Test Coverage (RSpec)

| Category | Files | What's Covered |
|---|---|---|
| Authentication | `spec/requests/auth_spec.rb` | Login success, invalid password, nonexistent user, `/me` with valid/invalid/missing token |
| Lead CRUD | `spec/requests/leads_spec.rb` | Create (public), list (paginated, filtered, scoped), show, update, delete — with admin & member roles |
| Lead Assignment | `spec/requests/leads_spec.rb` | Admin can assign, member cannot; status change by admin/assigned member |
| Notes | `spec/requests/leads_spec.rb` | Add note as admin, add note as assigned member |
| User Management | `spec/requests/users_spec.rb` | List users, create user (admin only), delete user (admin only) |
| Dashboard | `spec/requests/dashboard_spec.rb` | Stats for admin (all leads), stats for member (assigned only), unauthorized access |
| Models | `spec/models/user_spec.rb`, `lead_spec.rb`, `note_spec.rb`, `activity_spec.rb` | Validations, associations, enums, scopes, factories |
| Policies | `spec/policies/lead_policy_spec.rb` | Full Pundit policy matrix: index, show, create, update, destroy, assign, update_status, add_note — admin vs member vs non-assigned member |

#### Business Flows Covered

- ✅ Public lead submission flow (unauthenticated POST /api/leads)
- ✅ Authenticated admin flow (login → list all leads → view/edit/delete any lead → manage users)
- ✅ Authenticated member flow (login → list assigned leads only → view/edit assigned leads → add notes → change status)
- ✅ Permission enforcement (member cannot delete leads, assign leads, or access unassigned leads)
- ✅ Authentication enforcement (unauthenticated requests return 401)
- ✅ Pagination and filtering (search, status filter, assigned user filter)

### Frontend Tests

```bash
cd frontend
npm test
```

**Note:** Frontend tests are not yet implemented. The test command returns "Error: no test specified". To add tests, a testing framework such as Vitest or React Testing Library can be configured.

## Deployment

### Backend (Render)

1. Create a PostgreSQL database on [Neon](https://neon.tech)
2. Create a new Web Service on [Render](https://render.com)
3. Connect your Git repository
4. Set the following environment variables:
   - `DATABASE_URL`: Your Neon PostgreSQL connection string
   - `RAILS_MASTER_KEY`: Your Rails master key
   - `RAILS_ENV`: `production`
5. Set the build command: `bundle install && rails db:migrate`
6. Set the start command: `rails server -p $PORT`

### Frontend (Netlify)

1. Create a new site on [Netlify](https://netlify.com)
2. Connect your Git repository
3. Set the build command: `npm run build`
4. Set the publish directory: `dist`
5. Add environment variable: `VITE_API_URL` pointing to your Render backend URL

### Docker

Both services can be run with Docker:

```bash
# Backend
cd backend
docker build -t leadmanager-backend .
docker run -p 3000:3000 leadmanager-backend

# Frontend
cd frontend
docker build -t leadmanager-frontend .
docker run -p 5173:5173 leadmanager-frontend
```

## Demo Credentials

- **Admin**: `admin@example.com` / `password123`
- **Member**: `member1@example.com` / `password123`

## Assignment Requirement Verification

| Requirement | Status | Notes |
|---|---|---|
| Public Capture Form | ✅ | `/lead/new` route, no authentication required |
| JWT Authentication | ✅ | Token-based, 24-hour expiry, Bearer header |
| Admin Role | ✅ | Full access to all leads and management features |
| Member Role | ✅ | Restricted to assigned leads only |
| Client-side Authorization | ✅ | ProtectedRoute component, isAdmin UI checks |
| Server-side Authorization | ✅ | Pundit policies on all actions |
| Lead Assignment | ✅ | Admin can assign leads to any member |
| Notes with Timestamp | ✅ | Notes model with user, message, and timestamps |
| Activity Trail | ✅ | Actions tracked: lead_created, lead_assigned, status_changed, note_added |
| Pagination | ✅ | Kaminari gem, page/per_page parameters |
| Filtering | ✅ | Search, status filter, assigned user filter |
| Proper Status Codes | ✅ | 200, 201, 204, 401, 403, 404, 422 used appropriately |
| Automated Tests | ⚠️ | Backend only (RSpec) — frontend tests not implemented |
| Deployment | ❌ | Not yet deployed — no live URLs available |
| API Documentation | ✅ | Full documentation in this README |
| .env.example files | ✅ | `backend/.env.example` and `frontend/.env.example` |
| Permission Matrix | ✅ | Documented in Role Permissions section |
| ER Diagram & Relationships | ✅ | Documented in Database Schema section |

## Live Build Requirement

The frontend footer must display:

**"Built for Digital Heroes Training Task"**

linked to **https://digitalheroesco.com**

**Current Status:** ❌ Not implemented

**Implementation Note:** The footer should be added to `frontend/src/components/Layout.jsx` (for authenticated pages) and directly to `frontend/src/pages/Login.jsx` and `frontend/src/pages/PublicLeadForm.jsx` (for public pages). Example:

```jsx
<footer className="text-center py-4 text-sm text-gray-500 border-t border-gray-200">
  <a href="https://digitalheroesco.com" target="_blank" rel="noopener noreferrer" className="hover:text-indigo-600 transition">
    Built for Digital Heroes Training Task
  </a>
</footer>
```

## License

MIT License
