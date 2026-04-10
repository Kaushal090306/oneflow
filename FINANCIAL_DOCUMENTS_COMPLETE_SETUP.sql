-- ============================================================================
-- FINANCIAL DOCUMENTS - COMPLETE SETUP SQL
-- Features: Sales Orders, Purchase Orders, Customer Invoices, Vendor Bills, Expenses
-- 
-- Run this on a new device to set up all financial document tables with sample data
-- ============================================================================

-- ============================================================================
-- 1. SALES ORDERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS sales_orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  so_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Auto-generated: SO-YYYY-XXXX',
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(100),
  order_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  status ENUM('Draft', 'Confirmed', 'Billed') NOT NULL DEFAULT 'Draft',
  description TEXT,
  project_id INT,
  company_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  
  INDEX idx_so_company (company_id),
  INDEX idx_so_project (project_id),
  INDEX idx_so_status (status),
  INDEX idx_so_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Sales Orders - Customer purchase orders';

-- ============================================================================
-- 2. PURCHASE ORDERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS purchase_orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  po_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Auto-generated: PO-YYYY-XXXX',
  vendor_name VARCHAR(255) NOT NULL,
  vendor_email VARCHAR(100),
  order_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  status ENUM('Draft', 'Confirmed', 'Billed') NOT NULL DEFAULT 'Draft',
  description TEXT,
  project_id INT,
  company_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  
  INDEX idx_po_company (company_id),
  INDEX idx_po_project (project_id),
  INDEX idx_po_status (status),
  INDEX idx_po_date (order_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Purchase Orders - Orders to vendors/suppliers';

-- ============================================================================
-- 3. CUSTOMER INVOICES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS customer_invoices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  invoice_number VARCHAR(50) UNIQUE NOT NULL COMMENT 'Auto-generated: INV-YYYY-XXXX',
  customer_name VARCHAR(255) NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  status ENUM('Draft', 'Sent', 'Paid') NOT NULL DEFAULT 'Draft',
  description TEXT,
  project_id INT,
  company_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  
  INDEX idx_inv_company (company_id),
  INDEX idx_inv_project (project_id),
  INDEX idx_inv_status (status),
  INDEX idx_inv_date (invoice_date),
  INDEX idx_inv_due (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Customer Invoices - Bills sent to customers';

-- ============================================================================
-- 4. VENDOR BILLS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS vendor_bills (
  id INT PRIMARY KEY AUTO_INCREMENT,
  bill_number VARCHAR(50) NOT NULL COMMENT 'Vendor invoice/bill number',
  vendor_name VARCHAR(255) NOT NULL,
  bill_date DATE NOT NULL,
  due_date DATE,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  status ENUM('Draft', 'Submitted', 'Paid') NOT NULL DEFAULT 'Draft',
  description TEXT,
  project_id INT,
  company_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  
  INDEX idx_vb_company (company_id),
  INDEX idx_vb_project (project_id),
  INDEX idx_vb_status (status),
  INDEX idx_vb_date (bill_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Vendor Bills - Bills received from vendors/suppliers';

-- ============================================================================
-- 5. EXPENSES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS expenses (
  id INT PRIMARY KEY AUTO_INCREMENT,
  description VARCHAR(255) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  expense_date DATE NOT NULL,
  category ENUM('Travel', 'Meals', 'Supplies', 'Equipment', 'Software', 'Other') NOT NULL,
  status ENUM('Pending', 'Approved', 'Rejected', 'Reimbursed') NOT NULL DEFAULT 'Pending',
  receipt_url VARCHAR(500),
  notes TEXT,
  is_billable BOOLEAN DEFAULT FALSE COMMENT 'Can this be billed to customer?',
  user_id INT NOT NULL COMMENT 'Employee who incurred the expense',
  project_id INT COMMENT 'Project this expense is for',
  company_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  
  INDEX idx_exp_company (company_id),
  INDEX idx_exp_user (user_id),
  INDEX idx_exp_project (project_id),
  INDEX idx_exp_status (status),
  INDEX idx_exp_date (expense_date),
  INDEX idx_exp_billable (is_billable)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Expenses - Employee expense claims';

-- ============================================================================
-- SAMPLE DATA
-- ============================================================================

-- Note: Adjust IDs to match your existing companies, projects, and users

-- Sales Orders Sample Data
INSERT INTO sales_orders (so_number, customer_name, customer_email, order_date, amount, status, description, project_id, company_id) VALUES
('SO-2025-0001', 'Acme Corp', 'contact@acmecorp.com', '2025-01-15', 50000.00, 'Confirmed', 'Website development project - Phase 1', 3, 1),
('SO-2025-0002', 'TechStart Inc', 'billing@techstart.com', '2025-02-01', 75000.00, 'Draft', 'Mobile app development', 4, 1),
('SO-2025-0003', 'Global Solutions', 'orders@globalsol.com', '2025-03-10', 120000.00, 'Billed', 'ERP system customization', 3, 1);

-- Purchase Orders Sample Data
INSERT INTO purchase_orders (po_number, vendor_name, vendor_email, order_date, amount, status, description, project_id, company_id) VALUES
('PO-2025-0001', 'Cloud Services Ltd', 'sales@cloudservices.com', '2025-01-20', 15000.00, 'Confirmed', 'AWS hosting services for 1 year', 3, 1),
('PO-2025-0002', 'Software Supplies', 'contact@softwaresup.com', '2025-02-05', 8500.00, 'Draft', 'Development tools and licenses', 4, 1),
('PO-2025-0003', 'Hardware Depot', 'orders@hardwaredepot.com', '2025-03-01', 25000.00, 'Billed', 'Servers and networking equipment', 3, 1);

-- Customer Invoices Sample Data
INSERT INTO customer_invoices (invoice_number, customer_name, invoice_date, due_date, amount, status, description, project_id, company_id) VALUES
('INV-2025-0001', 'Acme Corp', '2025-01-20', '2025-02-20', 50000.00, 'Paid', 'Website development - Phase 1 completed', 3, 1),
('INV-2025-0002', 'TechStart Inc', '2025-02-10', '2025-03-10', 37500.00, 'Sent', 'Mobile app development - Milestone 1', 4, 1),
('INV-2025-0003', 'Global Solutions', '2025-03-15', '2025-04-15', 60000.00, 'Draft', 'ERP customization - Phase 1', 3, 1);

-- Vendor Bills Sample Data
INSERT INTO vendor_bills (bill_number, vendor_name, bill_date, due_date, amount, status, description, project_id, company_id) VALUES
('BILL-CS-2025-001', 'Cloud Services Ltd', '2025-01-25', '2025-02-25', 15000.00, 'Paid', 'AWS hosting invoice for January', 3, 1),
('BILL-SS-2025-001', 'Software Supplies', '2025-02-10', '2025-03-10', 8500.00, 'Submitted', 'Software licenses invoice', 4, 1),
('BILL-HD-2025-001', 'Hardware Depot', '2025-03-05', '2025-04-05', 25000.00, 'Draft', 'Server hardware invoice', 3, 1);

-- Expenses Sample Data
INSERT INTO expenses (description, amount, expense_date, category, status, is_billable, user_id, project_id, company_id) VALUES
('Client meeting lunch', 850.00, '2025-01-15', 'Meals', 'Approved', TRUE, 1, 3, 1),
('Flight to Delhi for project demo', 5500.00, '2025-02-01', 'Travel', 'Reimbursed', TRUE, 1, 4, 1),
('Office supplies - sticky notes, markers', 350.00, '2025-02-15', 'Supplies', 'Approved', FALSE, 15, 3, 1),
('Annual IDE license', 12000.00, '2025-03-01', 'Software', 'Pending', FALSE, 15, 4, 1),
('Laptop for new developer', 65000.00, '2025-03-10', 'Equipment', 'Pending', FALSE, 1, 3, 1);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these to verify data was inserted correctly

-- Check Sales Orders
SELECT 
    'Sales Orders' as document_type,
    COUNT(*) as total,
    SUM(amount) as total_amount
FROM sales_orders;

-- Check Purchase Orders
SELECT 
    'Purchase Orders' as document_type,
    COUNT(*) as total,
    SUM(amount) as total_amount
FROM purchase_orders;

-- Check Customer Invoices
SELECT 
    'Customer Invoices' as document_type,
    COUNT(*) as total,
    SUM(amount) as total_amount
FROM customer_invoices;

-- Check Vendor Bills
SELECT 
    'Vendor Bills' as document_type,
    COUNT(*) as total,
    SUM(amount) as total_amount
FROM vendor_bills;

-- Check Expenses
SELECT 
    'Expenses' as document_type,
    COUNT(*) as total,
    SUM(amount) as total_amount
FROM expenses;

-- ============================================================================
-- FINANCIAL SUMMARY BY PROJECT
-- ============================================================================

SELECT 
    p.id as project_id,
    p.name as project_name,
    COALESCE(SUM(so.amount), 0) as total_sales_orders,
    COALESCE(SUM(po.amount), 0) as total_purchase_orders,
    COALESCE(SUM(ci.amount), 0) as total_invoices,
    COALESCE(SUM(vb.amount), 0) as total_vendor_bills,
    COALESCE(SUM(e.amount), 0) as total_expenses,
    (COALESCE(SUM(ci.amount), 0) - COALESCE(SUM(vb.amount), 0) - COALESCE(SUM(e.amount), 0)) as net_profit
FROM projects p
LEFT JOIN sales_orders so ON p.id = so.project_id
LEFT JOIN purchase_orders po ON p.id = po.project_id
LEFT JOIN customer_invoices ci ON p.id = ci.project_id
LEFT JOIN vendor_bills vb ON p.id = vb.project_id
LEFT JOIN expenses e ON p.id = e.project_id
GROUP BY p.id, p.name
ORDER BY p.id;

-- ============================================================================
-- AUTO-INCREMENT TRIGGERS FOR DOCUMENT NUMBERS
-- ============================================================================

-- Note: These require stored procedures or application-level logic
-- The current implementation uses Node.js backend to auto-generate numbers

-- Sales Order Number Format: SO-YYYY-XXXX (e.g., SO-2025-0001)
-- Purchase Order Number Format: PO-YYYY-XXXX (e.g., PO-2025-0001)
-- Invoice Number Format: INV-YYYY-XXXX (e.g., INV-2025-0001)
-- Bill numbers are vendor-provided (no auto-generation)

-- ============================================================================
-- MIGRATION: Add company_id if missing (for existing installations)
-- ============================================================================

-- Only run if upgrading from older version without company_id

-- Add company_id to sales_orders if not exists
ALTER TABLE sales_orders 
ADD COLUMN IF NOT EXISTS company_id INT NOT NULL DEFAULT 1 AFTER project_id,
ADD FOREIGN KEY IF NOT EXISTS (company_id) REFERENCES companies(id) ON DELETE CASCADE;

-- Add company_id to purchase_orders if not exists
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS company_id INT NOT NULL DEFAULT 1 AFTER project_id,
ADD FOREIGN KEY IF NOT EXISTS (company_id) REFERENCES companies(id) ON DELETE CASCADE;

-- Add company_id to customer_invoices if not exists
ALTER TABLE customer_invoices 
ADD COLUMN IF NOT EXISTS company_id INT NOT NULL DEFAULT 1 AFTER project_id,
ADD FOREIGN KEY IF NOT EXISTS (company_id) REFERENCES companies(id) ON DELETE CASCADE;

-- Add company_id to vendor_bills if not exists
ALTER TABLE vendor_bills 
ADD COLUMN IF NOT EXISTS company_id INT NOT NULL DEFAULT 1 AFTER project_id,
ADD FOREIGN KEY IF NOT EXISTS (company_id) REFERENCES companies(id) ON DELETE CASCADE;

-- Add company_id to expenses if not exists
ALTER TABLE expenses 
ADD COLUMN IF NOT EXISTS company_id INT NOT NULL DEFAULT 1 AFTER project_id,
ADD FOREIGN KEY IF NOT EXISTS (company_id) REFERENCES companies(id) ON DELETE CASCADE;

-- ============================================================================
-- USEFUL QUERIES FOR ADMIN DASHBOARD
-- ============================================================================

-- Total Revenue (All Paid/Sent Invoices)
SELECT 
    SUM(amount) as total_revenue 
FROM customer_invoices 
WHERE status IN ('Sent', 'Paid')
  AND company_id = 1;

-- Total Expenses (Approved/Reimbursed)
SELECT 
    SUM(amount) as total_expenses 
FROM expenses 
WHERE status IN ('Approved', 'Reimbursed')
  AND company_id = 1;

-- Profit Calculation
SELECT 
    (SELECT COALESCE(SUM(amount), 0) FROM customer_invoices 
     WHERE status IN ('Sent', 'Paid') AND company_id = 1) -
    (SELECT COALESCE(SUM(amount), 0) FROM vendor_bills 
     WHERE status IN ('Submitted', 'Paid') AND company_id = 1) -
    (SELECT COALESCE(SUM(amount), 0) FROM expenses 
     WHERE status IN ('Approved', 'Reimbursed') AND company_id = 1)
    as net_profit;

-- Pending Approvals
SELECT 
    'Sales Orders' as type, COUNT(*) as pending 
FROM sales_orders 
WHERE status = 'Draft' AND company_id = 1
UNION ALL
SELECT 
    'Purchase Orders', COUNT(*) 
FROM purchase_orders 
WHERE status = 'Draft' AND company_id = 1
UNION ALL
SELECT 
    'Customer Invoices', COUNT(*) 
FROM customer_invoices 
WHERE status = 'Draft' AND company_id = 1
UNION ALL
SELECT 
    'Vendor Bills', COUNT(*) 
FROM vendor_bills 
WHERE status = 'Draft' AND company_id = 1
UNION ALL
SELECT 
    'Expenses', COUNT(*) 
FROM expenses 
WHERE status = 'Pending' AND company_id = 1;

-- ============================================================================
-- PROJECT FINANCIAL SUMMARY
-- ============================================================================

CREATE OR REPLACE VIEW project_financials AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    p.budget,
    
    -- Revenue
    (SELECT COALESCE(SUM(amount), 0) FROM customer_invoices 
     WHERE project_id = p.id AND status IN ('Sent', 'Paid')) as total_revenue,
    
    -- Costs
    (SELECT COALESCE(SUM(amount), 0) FROM vendor_bills 
     WHERE project_id = p.id AND status IN ('Submitted', 'Paid')) as vendor_costs,
    
    (SELECT COALESCE(SUM(amount), 0) FROM expenses 
     WHERE project_id = p.id AND status IN ('Approved', 'Reimbursed')) as expense_costs,
    
    (SELECT COALESCE(SUM(cost), 0) FROM timesheets ts
     JOIN tasks t ON ts.task_id = t.id
     WHERE t.project_id = p.id) as labor_costs,
    
    -- Profit
    (SELECT COALESCE(SUM(amount), 0) FROM customer_invoices 
     WHERE project_id = p.id AND status IN ('Sent', 'Paid')) -
    (SELECT COALESCE(SUM(amount), 0) FROM vendor_bills 
     WHERE project_id = p.id AND status IN ('Submitted', 'Paid')) -
    (SELECT COALESCE(SUM(amount), 0) FROM expenses 
     WHERE project_id = p.id AND status IN ('Approved', 'Reimbursed')) -
    (SELECT COALESCE(SUM(cost), 0) FROM timesheets ts
     JOIN tasks t ON ts.task_id = t.id
     WHERE t.project_id = p.id) as profit
     
FROM projects p;

-- Use the view:
SELECT * FROM project_financials WHERE project_id = 3;

-- ============================================================================
-- CLEANUP (if you need to start fresh)
-- ============================================================================

-- WARNING: This will delete ALL financial data!
-- Uncomment only if you want to reset everything

-- DROP TABLE IF EXISTS sales_orders;
-- DROP TABLE IF EXISTS purchase_orders;
-- DROP TABLE IF EXISTS customer_invoices;
-- DROP TABLE IF EXISTS vendor_bills;
-- DROP TABLE IF EXISTS expenses;
-- DROP VIEW IF EXISTS project_financials;

-- ============================================================================
-- PERMISSION GRANTS (if using specific MySQL users)
-- ============================================================================

-- Grant permissions to your application user
-- GRANT SELECT, INSERT, UPDATE, DELETE ON oneflow.sales_orders TO 'oneflow_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON oneflow.purchase_orders TO 'oneflow_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON oneflow.customer_invoices TO 'oneflow_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON oneflow.vendor_bills TO 'oneflow_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON oneflow.expenses TO 'oneflow_user'@'localhost';
-- FLUSH PRIVILEGES;

-- ============================================================================
-- NOTES FOR NEW DEVICE SETUP
-- ============================================================================

/*
1. PREREQUISITES:
   - MySQL 5.7+ or MariaDB 10.2+
   - Database 'oneflow' must exist
   - Tables 'companies', 'projects', 'users', 'tasks' must exist first

2. SETUP STEPS:
   a. Create database: CREATE DATABASE oneflow;
   b. Run base schema (users, companies, projects, tasks)
   c. Run this file: source FINANCIAL_DOCUMENTS_COMPLETE_SETUP.sql
   d. Verify data: Run verification queries above

3. BACKEND REQUIREMENTS:
   - Node.js models must match these tables
   - API routes for CRUD operations
   - Files needed:
     * server/models/SalesOrder.js
     * server/models/PurchaseOrder.js
     * server/models/CustomerInvoice.js
     * server/models/VendorBill.js
     * server/models/Expense.js
     * server/routes/salesOrders.js
     * server/routes/purchaseOrders.js
     * server/routes/customerInvoices.js
     * server/routes/vendorBills.js
     * server/routes/expenses.js

4. FRONTEND REQUIREMENTS:
   - Settings page with document lists
   - Form components for create/edit
   - Files needed:
     * client/src/pages/Settings/SalesOrdersList.js
     * client/src/pages/Settings/SalesOrderForm.js
     * (similar for other documents)

5. INTEGRATION:
   - Documents link to projects via project_id
   - Projects link to companies via company_id
   - Multi-tenancy enforced through company_id
   - Admin can see ALL documents in their company

6. AUTO-NUMBERING:
   Document numbers are auto-generated by backend:
   - SO-2025-0001, SO-2025-0002, ...
   - PO-2025-0001, PO-2025-0002, ...
   - INV-2025-0001, INV-2025-0002, ...
   
   Backend checks max number for current year and increments.

7. TESTING:
   - Create documents through UI
   - Verify they appear in Settings page
   - Link to projects
   - Check dashboard shows correct revenue
   - Verify multi-tenancy (create Company 2 data, ensure Company 1 admin can't see it)
*/

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

