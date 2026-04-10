# Database Migration Guide

## Problem
The application is showing these errors:
- `Unknown column 'SalesOrder.description'`
- `Unknown column 'PurchaseOrder.description'`
- `Unknown column 'CustomerInvoice.description'`
- `Unknown column 'VendorBill.description'`
- `Unknown column 'Expense.is_billable'`

## Solution
The models expect different column names than what exists in the database. We need to rename some columns.

## How to Run the Migration

### Option 1: Using MySQL Workbench or phpMyAdmin

1. Open MySQL Workbench or phpMyAdmin
2. Connect to your database
3. Select the `oneflow_db` database
4. Open and run the SQL file: `database_migrations/ADD_MISSING_COLUMNS.sql`
5. Check for success messages

### Option 2: Using MySQL Command Line

```bash
# Windows PowerShell
cd D:\odoo\odoo-oneflow
mysql -u root -p oneflow_db < database_migrations/ADD_MISSING_COLUMNS.sql
```

### Option 3: Using Node.js Script

```bash
cd server
node -e "
const mysql = require('mysql2/promise');
const fs = require('fs');

async function runMigration() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'your_password_here',
    database: 'oneflow_db',
    multipleStatements: true
  });
  
  const sql = fs.readFileSync('../database_migrations/ADD_MISSING_COLUMNS.sql', 'utf8');
  await connection.query(sql);
  console.log('✅ Migration completed successfully!');
  await connection.end();
}

runMigration().catch(console.error);
"
```

## What This Migration Does

### 1. Sales Orders
- Renames `notes` → `description`

### 2. Purchase Orders
- Renames `notes` → `description`

### 3. Customer Invoices
- Renames `notes` → `description`

### 4. Vendor Bills
- Renames `notes` → `description`

### 5. Expenses
- Renames `receipt_path` → `receipt_url` (and increases size to 500)

## Additional Fix For Auth + Dashboard 500 Errors

If you see errors like:
- `Unknown column 'first_name' in 'field list'`
- `Unknown column 'Project.company_id' in 'where clause'`
- Dashboard endpoints returning 500 on recent tasks/analytics

Run this additional migration file:

```bash
# Windows PowerShell
cd D:\odoo\odoo-oneflow
mysql -u root -p oneflow_db < database_migrations/FIX_AUTH_DASHBOARD_SCHEMA.sql
```

This migration:
- Adds missing columns in `users` (`first_name`, `last_name`, `company_id`, `created_by`, `can_manage_users`)
- Adds missing `projects.company_id` and backfills company mappings
- Adds missing `tasks.cover_image`
- Backfills legacy `name` data into `first_name`/`last_name`

## After Running Migration

1. **Restart the server**:
```bash
cd server
# Stop server (Ctrl+C)
npm start
```

2. **Verify in browser**:
   - Go to Settings → Sales Orders, Purchase Orders, etc.
   - Documents should now load without errors
   - The "No recent documents found" message should disappear if you have data

## Rollback (if needed)

If you need to undo these changes:

```sql
-- Rollback sales_orders
ALTER TABLE sales_orders CHANGE COLUMN description notes TEXT;

-- Rollback purchase_orders
ALTER TABLE purchase_orders CHANGE COLUMN description notes TEXT;

-- Rollback customer_invoices
ALTER TABLE customer_invoices CHANGE COLUMN description notes TEXT;

-- Rollback vendor_bills
ALTER TABLE vendor_bills CHANGE COLUMN description notes TEXT;

-- Rollback expenses
ALTER TABLE expenses CHANGE COLUMN receipt_url receipt_path VARCHAR(255);
```

## Need Help?

If you encounter any issues:
1. Check that you're connected to the correct database
2. Ensure you have ALTER TABLE permissions
3. Make a backup before running migrations
4. Share the error message if something fails

