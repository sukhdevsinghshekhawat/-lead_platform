# LeadManager CRM

A production-ready Lead Management Application built with Ruby on Rails 8 (API-only) and React 19.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Database Schema](#database-schema)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)

## Overview

LeadManager CRM is a full-featured lead management system designed for small sales teams. It provides public lead capture, JWT-based authentication, role-based authorization (Admin/Member), lead lifecycle management, notes, activity timeline, and a professional dashboard.

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

### Notes
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `lead_id` | bigint | Foreign key to leads |
| `user_id` | bigint | Foreign key to users |
| `message` | text | Note content |
| `created_at` | datetime | |
| `updated_at` | datetime | |

### Activities
| Column | Type | Description |
|--------|------|-------------|
| `id` | bigint | Primary key |
| `lead_id` | bigint | Foreign key to leads |
| `user_id` | bigint | Foreign key to users (nullable) |
| `action` | string | lead_created, lead_assigned, status_changed, note_added |
| `details` | text | Human-readable description |
| `created_at` | datetime | |

## API Documentation

All endpoints return JSON. Authenticated endpoints require `Authorization: Bearer <token>` header.

### Authentication

#### POST /api/login
Login with email and password.

**Request:**
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response (200):**
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

#### GET /api/me
Get current authenticated user.

**Response (200):**
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

### Leads

#### GET /api/leads
List leads with pagination, search, and filtering.

**Query Parameters:**
- `page` (default: 1)
- `per_page` (default: 10)
- `search` (optional)
- `status` (optional: new_lead, contacted, qualified, proposal_sent, won, lost)
- `assigned_to_id` (optional)

**Response (200):**
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
    "next_page": 2,
    "prev_page": null,
    "total_pages": 3,
    "total_count": 25,
    "limit": 10
  }
}
```

#### GET /api/leads/:id
Get lead details with notes and activities.

**Response (200):**
```json
{
  "lead": { ... },
  "notes": [ ... ],
  "activities": [ ... ]
}
```

#### POST /api/leads
Create a new lead (public, no authentication required).

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

**Response (201):**
```json
{
  "data": { ... }
}
```

#### PATCH /api/leads/:id
Update lead details (admin or assigned member).

#### DELETE /api/leads/:id
Delete a lead (admin only).

**Response (204):** No content

#### PATCH /api/leads/:id/update_status
Update lead status (admin or assigned member).

**Request:**
```json
{
  "status": "contacted"
}
```

#### PATCH /api/leads/:id/assign
Assign lead to a user (admin only).

**Request:**
```json
{
  "assigned_to_id": 2
}
```

#### POST /api/leads/:id/add_note
Add a note to a lead (admin or assigned member).

**Request:**
```json
{
  "message": "Called the customer, left a voicemail"
}
```

**Response (201):**
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

### Users

#### GET /api/users
List all users (authenticated).

#### POST /api/users
Create a new user (admin only).

#### DELETE /api/users/:id
Delete a user (admin only).

### Dashboard

#### GET /api/dashboard
Get dashboard statistics.

**Response (200):**
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

- **Authentication Tests**: Login, token validation, unauthorized access
- **Authorization Tests**: Admin vs Member permissions for all actions
- **CRUD Tests**: Lead creation, listing, details, update, delete
- **Lead Assignment Tests**: Admin assignment, member restrictions
- **Model Tests**: Validations, associations, enums, scopes
- **Policy Tests**: Pundit policy rules for all actions

### Frontend Tests

```bash
cd frontend
npm test
```

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

## License

MIT License
