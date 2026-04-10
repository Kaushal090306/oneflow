<<<<<<< HEAD
# oneflow
A company management system
=======
# OneFlow

OneFlow is a full-stack project management and financial operations platform designed for teams that need to manage delivery and business documents in one system. It combines project planning, task execution, timesheet tracking, and finance workflows (sales orders, purchase orders, invoices, vendor bills, and expenses) in a single web application.


## Overview

OneFlow is built as a monorepo-style project with:

- A React frontend (`client`) for the user interface and workflow interactions.
- A Node.js + Express backend (`server`) for REST APIs, authentication, and business logic.
- A MySQL database accessed through Sequelize models.
- Socket.IO for real-time notification delivery.

The system is role-aware and includes route-level restrictions for administrative and finance-sensitive operations.

## Core Features

- Authentication and account flows:
  - Login, registration, forgot password, and reset password.
- Project execution workflows:
  - Projects, project details, task management, and dashboards.
- Timesheet management:
  - User timesheet entry and tracking.
- Analytics and reporting:
  - KPI and chart-based analytics views.
- Financial document management:
  - Sales Orders
  - Purchase Orders
  - Customer Invoices
  - Vendor Bills
  - Expenses (with receipt uploads)
- User and profile management:
  - Role-restricted user administration and profile pages.
- Real-time notifications:
  - Socket.IO-powered notification updates.

## Tech Stack

### Frontend

- React 18
- React Router 6
- Redux Toolkit
- Tailwind CSS
- Recharts + Chart.js
- Axios
- Socket.IO Client

### Backend

- Node.js + Express
- Sequelize ORM
- MySQL (`mysql2`)
- JWT authentication (`jsonwebtoken`)
- Password hashing (`bcryptjs`)
- File upload handling (`multer`)
- Email service (`nodemailer`)
- Socket.IO

## Project Structure

```text
oneflow/
├─ client/                  # React frontend
│  ├─ src/
│  ├─ public/
│  └─ package.json
├─ server/                  # Express API + business logic
│  ├─ config/
│  ├─ middleware/
│  ├─ models/
│  ├─ routes/
│  ├─ services/
│  ├─ uploads/
│  └─ package.json
├─ database_migrations/     # SQL migration scripts
├─ FINANCIAL_DOCUMENTS_COMPLETE_SETUP.sql
├─ start-dev.bat            # Windows helper to start both apps
├─ start-dev.sh             # Linux/macOS helper to start both apps
└─ RUN_MIGRATION_GUIDE.md
```

## Prerequisites

Install the following before running locally:

- Node.js 18+ (recommended)
- npm 9+
- MySQL 8+

## Getting Started

### 1. Clone and install dependencies

```bash
# from repository root
cd server
npm install

cd ../client
npm install
```

### 2. Configure environment variables

Create a `.env` file in `server` and populate required values (see [Environment Configuration](#environment-configuration)).

### 3. Initialize database

Create the database and run SQL setup/migrations (see [Database Setup and Migrations](#database-setup-and-migrations)).

### 4. Run the application

#### Option A: Start both services with helper scripts

Windows:

```powershell
./start-dev.bat
```

Linux/macOS:

```bash
chmod +x start-dev.sh
./start-dev.sh
```

#### Option B: Start services manually

Backend:

```bash
cd server
npm run dev
```

Frontend (in another terminal):

```bash
cd client
npm start
```

### 5. Access application

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000`
- Health endpoint: `http://localhost:5000/api/health`

## Environment Configuration

Create `server/.env` with the following keys:

```env
# App
NODE_ENV=development
PORT=5000
CLIENT_URL=http://localhost:3000

# Database
DB_HOST=localhost
DB_PORT=3306
DB_NAME=oneflow_db
DB_USER=your_mysql_user
DB_PASSWORD=your_mysql_password

# Auth
JWT_SECRET=replace_with_a_strong_secret
JWT_EXPIRE=7d

# Email (used for password reset and notifications)
EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_USER=your_email_user
EMAIL_PASSWORD=your_email_password
EMAIL_FROM=no-reply@example.com
```

## Database Setup and Migrations

### Base setup

- Run the base SQL setup script:

```sql
FINANCIAL_DOCUMENTS_COMPLETE_SETUP.sql
```

### Migration scripts

Run these scripts if your schema is missing columns expected by current models/routes:

```sql
database_migrations/ADD_MISSING_COLUMNS.sql
database_migrations/FIX_AUTH_DASHBOARD_SCHEMA.sql
```

Detailed migration instructions are available in `RUN_MIGRATION_GUIDE.md`.

## Available Scripts

### Root scripts

- `start-dev.bat`: Installs missing dependencies (if needed) and starts backend + frontend on Windows.
- `start-dev.sh`: Installs missing dependencies (if needed) and starts backend + frontend on Linux/macOS.

### Server (`server/package.json`)

- `npm start`: Start backend with Node.
- `npm run dev`: Start backend with Nodemon.
- `npm test`: Run server tests (Jest).
- `npm run seed`: Run seed script.
- `npm run seed-data`: Run test data seed script.

### Client (`client/package.json`)

- `npm start`: Start React development server.
- `npm run build`: Build production frontend assets.
- `npm test`: Run frontend tests.

## API and Realtime

### Core REST route groups

- `/api/auth`
- `/api/users`
- `/api/companies`
- `/api/projects`
- `/api/tasks`
- `/api/timesheets`
- `/api/sales-orders`
- `/api/purchase-orders`
- `/api/customer-invoices`
- `/api/vendor-bills`
- `/api/expenses`
- `/api/notifications`
- `/api/dashboard`

### Realtime notifications

Socket.IO is enabled on the backend server and supports user-specific rooms for notification events.

## Troubleshooting

- CORS errors:
  - Verify `CLIENT_URL` in `server/.env` matches the frontend origin.
- Database connection failures:
  - Confirm MySQL is running and `DB_*` variables are correct.
- 500 errors on dashboard/auth or missing finance fields:
  - Apply scripts in `database_migrations` per `RUN_MIGRATION_GUIDE.md`.
- Upload issues:
  - Ensure backend can write to `server/uploads/receipts`.

---

For production deployment, consider adding separate environment files, secure secret management, and CI/CD pipeline checks for schema migrations.
>>>>>>> 5fe7bec (Initial commit: OneFlow project setup and documentation)
