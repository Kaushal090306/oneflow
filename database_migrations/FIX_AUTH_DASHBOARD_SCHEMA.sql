-- ============================================
-- DATABASE MIGRATION: Fix Auth + Dashboard Schema Drift
-- ============================================
-- Purpose:
-- 1) Align users table with Sequelize User model
-- 2) Align projects table with company-scoped queries
-- 3) Align tasks table with Sequelize Task model
--
-- Safe to run multiple times.
-- ============================================

USE oneflow_db;

-- ---------- USERS TABLE ----------
-- Add missing columns used by User model (compatible with MySQL versions
-- that do not support ADD COLUMN IF NOT EXISTS)

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'first_name'
    ),
    'SELECT "users.first_name already exists"',
    'ALTER TABLE users ADD COLUMN first_name VARCHAR(100) NOT NULL DEFAULT '''''' AFTER id'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'last_name'
    ),
    'SELECT "users.last_name already exists"',
    'ALTER TABLE users ADD COLUMN last_name VARCHAR(100) NOT NULL DEFAULT '''''' AFTER first_name'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'company_id'
    ),
    'SELECT "users.company_id already exists"',
    'ALTER TABLE users ADD COLUMN company_id INT NULL AFTER reset_password_expire'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'created_by'
    ),
    'SELECT "users.created_by already exists"',
    'ALTER TABLE users ADD COLUMN created_by INT NULL AFTER company_id'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'can_manage_users'
    ),
    'SELECT "users.can_manage_users already exists"',
    'ALTER TABLE users ADD COLUMN can_manage_users TINYINT(1) NOT NULL DEFAULT 0 AFTER created_by'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Backfill names from legacy name column when needed
UPDATE users
SET first_name = CASE
  WHEN first_name IS NULL OR TRIM(first_name) = '' THEN
    CASE
      WHEN name IS NULL OR TRIM(name) = '' THEN
        CASE
          WHEN email IS NULL OR TRIM(email) = '' THEN 'User'
          ELSE SUBSTRING_INDEX(
            REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
            ' ',
            1
          )
        END
      ELSE SUBSTRING_INDEX(TRIM(name), ' ', 1)
    END
  ELSE first_name
END;

UPDATE users
SET last_name = CASE
  WHEN last_name IS NULL OR TRIM(last_name) = '' THEN
    CASE
      WHEN name IS NULL OR TRIM(name) = '' THEN
        CASE
          WHEN email IS NULL OR TRIM(email) = '' THEN ''
          ELSE TRIM(
            SUBSTRING(
              REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
              LENGTH(
                SUBSTRING_INDEX(
                  REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
                  ' ',
                  1
                )
              ) + 1
            )
          )
        END
      WHEN TRIM(name) LIKE '% %' THEN TRIM(SUBSTRING(TRIM(name), LENGTH(SUBSTRING_INDEX(TRIM(name), ' ', 1)) + 1))
      ELSE ''
    END
  ELSE last_name
END;

-- Repair existing placeholder names like "User User" when name is not meaningful
UPDATE users
SET
  first_name = CASE
    WHEN email IS NULL OR TRIM(email) = '' THEN first_name
    ELSE SUBSTRING_INDEX(
      REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
      ' ',
      1
    )
  END,
  last_name = CASE
    WHEN email IS NULL OR TRIM(email) = '' THEN last_name
    ELSE TRIM(
      SUBSTRING(
        REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
        LENGTH(
          SUBSTRING_INDEX(
            REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(email), '@', 1), '.', ' '), '_', ' '), '-', ' '),
            ' ',
            1
          )
        ) + 1
      )
    )
  END
WHERE LOWER(TRIM(first_name)) = 'user'
  AND (TRIM(last_name) = '' OR LOWER(TRIM(last_name)) = 'user')
  AND (name IS NULL OR TRIM(name) = '' OR LOWER(TRIM(name)) IN ('user', 'user user'));

-- Ensure admin users can manage users
UPDATE users
SET can_manage_users = 1
WHERE role = 'Admin';

-- ---------- PROJECTS TABLE ----------
-- Add missing company_id used by role/company-scoped filters
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'projects'
        AND COLUMN_NAME = 'company_id'
    ),
    'SELECT "projects.company_id already exists"',
    'ALTER TABLE projects ADD COLUMN company_id INT NULL AFTER project_manager_id'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Backfill users.company_id and projects.company_id for legacy single-company data
SET @default_company_id = (SELECT id FROM companies ORDER BY id ASC LIMIT 1);

UPDATE users
SET company_id = @default_company_id
WHERE company_id IS NULL
  AND @default_company_id IS NOT NULL;

UPDATE projects p
LEFT JOIN users u ON u.id = p.project_manager_id
SET p.company_id = COALESCE(u.company_id, @default_company_id)
WHERE p.company_id IS NULL
  AND @default_company_id IS NOT NULL;

SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'projects'
        AND INDEX_NAME = 'idx_projects_company_id'
    ),
    'SELECT "idx_projects_company_id already exists"',
    'CREATE INDEX idx_projects_company_id ON projects(company_id)'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------- TASKS TABLE ----------
-- Add missing cover_image column used by Task model
SET @sql = (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'tasks'
        AND COLUMN_NAME = 'cover_image'
    ),
    'SELECT "tasks.cover_image already exists"',
    'ALTER TABLE tasks ADD COLUMN cover_image TEXT NULL AFTER status'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------- VERIFICATION ----------
-- SHOW COLUMNS FROM users;
-- SHOW COLUMNS FROM projects;
-- SHOW COLUMNS FROM tasks;
