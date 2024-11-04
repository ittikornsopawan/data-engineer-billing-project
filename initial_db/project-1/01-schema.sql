-- Create ENUM type for row_status
DO $$ 
BEGIN
    CREATE TYPE enum_row_status AS ENUM ('active', 'inactive', 'suspended', 'archived', 'deleted');
EXCEPTION
    WHEN duplicate_object THEN NULL; -- Ignore error if type already exists
END $$;

-- Create schemas if not exist
CREATE SCHEMA IF NOT EXISTS master;
CREATE SCHEMA IF NOT EXISTS project;
CREATE SCHEMA IF NOT EXISTS product;
CREATE SCHEMA IF NOT EXISTS transaction;

-- Create master.m_account_types table
CREATE TABLE IF NOT EXISTS master.m_account_types
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(128) NOT NULL,
    group_name VARCHAR(128) NOT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create master.m_accounts table
CREATE TABLE IF NOT EXISTS master.m_accounts
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(128) NOT NULL,
    account_type_id UUID NOT NULL REFERENCES master.m_account_types(id),
    parent_account_id UUID REFERENCES master.m_accounts(id),
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    row_status enum_row_status DEFAULT 'active'
);

-- Create master.m_discount_programs table
CREATE TABLE IF NOT EXISTS master.m_discount_programs
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(128) NOT NULL,
    discount_type VARCHAR(16) NOT NULL CHECK (discount_type IN ('fixed', 'tier')),
    unit_type VARCHAR(16) NOT NULL CHECK (unit_type IN ('percentage', 'currency')),
    min_value DECIMAL(10, 2),
    max_value DECIMAL(10, 2),
    start_date TIMESTAMP NOT NULL DEFAULT current_timestamp,
    end_date TIMESTAMP,
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    row_status enum_row_status DEFAULT 'active'
);

-- Create master.m_account_discount_programs table
CREATE TABLE IF NOT EXISTS master.m_account_discount_programs
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    account_id UUID NOT NULL REFERENCES master.m_accounts(id),
    discount_program_id UUID NOT NULL REFERENCES master.m_discount_programs(id),
    min_value DECIMAL(10, 2) NOT NULL,
    is_forwarded BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    row_status enum_row_status DEFAULT 'active'
);

-- create project.t_projects
CREATE TABLE IF NOT EXISTS project.t_projects
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(128) NOT NULL,
    account_id UUID NOT NULL REFERENCES master.m_accounts(id),
    description TEXT,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create product.m_product_categories table
CREATE TABLE IF NOT EXISTS product.m_product_categories
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create product.m_products table
CREATE TABLE IF NOT EXISTS product.m_products
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    product_category_id UUID NOT NULL REFERENCES product.m_product_categories(id),
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create product.m_product_specifications table
CREATE TABLE IF NOT EXISTS product.m_product_specifications 
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    product_id UUID NOT NULL REFERENCES product.m_products(id),
    specification JSONB NOT NULL,
    unit VARCHAR(64) NOT NULL,
    effectived_date TIMESTAMP DEFAULT current_timestamp,
    expired_date TIMESTAMP DEFAULT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_dates CHECK (expired_date IS NULL OR expired_date >= effectived_date)
);

-- Create product.m_pricing_model table
CREATE TABLE IF NOT EXISTS product.m_pricing_model
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES product.m_products(id),
    product_spec_id UUID NOT NULL REFERENCES product.m_product_specifications(id),
    billing_cycle VARCHAR(64) NOT NULL,
    pricing_unit VARCHAR(128) NOT NULL,
    price_per_unit DECIMAL(18, 12) DEFAULT 0.0,
    tier JSONB,
    usage_value DECIMAL(24,12) DEFAULT NULL,
    usage_type VARCHAR(64) NOT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create transaction.t_instances table
CREATE TABLE IF NOT EXISTS transaction.t_instances
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    account_id UUID NOT NULL REFERENCES master.m_accounts(id),
    product_id UUID NOT NULL REFERENCES product.m_products(id),
    product_spec_id UUID NOT NULL REFERENCES product.m_product_specifications(id),
    project_id UUID NOT NULL REFERENCES project.t_projects(id),
    pricing_model_id UUID NOT NULL REFERENCES product.m_pricing_model(id),
    effectived_date TIMESTAMP DEFAULT current_timestamp,
    expired_date TIMESTAMP DEFAULT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
    CONSTRAINT check_dates CHECK (expired_date IS NULL OR expired_date >= effectived_date)
);

-- Create transaction.t_instance_usages table
CREATE TABLE IF NOT EXISTS transaction.t_instance_usages
(
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    instance_id UUID NOT NULL REFERENCES transaction.t_instances(id),
    pricing_model_id UUID NOT NULL REFERENCES product.m_pricing_model(id),
    period VARCHAR(16) NOT NULL,
    period_begin_date TIMESTAMP NOT NULL,
    period_end_date TIMESTAMP NOT NULL,
    usage DECIMAL(24,12) DEFAULT NULL,
    usage_date TIMESTAMP DEFAULT current_timestamp,
    unblended_cost DECIMAL(24,12) DEFAULT NULL,
    unblended_rate DECIMAL(24,12) DEFAULT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create indexes to improve performance on frequently queried columns
CREATE INDEX IF NOT EXISTS idx_account_id ON transaction.t_instances(account_id);
CREATE INDEX IF NOT EXISTS idx_product_id ON transaction.t_instances(product_id);
CREATE INDEX IF NOT EXISTS idx_product_spec_id ON transaction.t_instances(product_spec_id);
CREATE INDEX IF NOT EXISTS idx_pricing_model_id ON transaction.t_instance_usages(pricing_model_id);


-- Marketplace
CREATE SCHEMA IF NOT EXISTS marketplace;

CREATE TABLE IF NOT EXISTS marketplace.m_vendors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS marketplace.m_products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(256) NOT NULL,
    description TEXT,
    product_category_id UUID NOT NULL REFERENCES product.m_product_categories(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES marketplace.m_vendors(id) ON DELETE CASCADE,
    price_per_unit DECIMAL(18, 12) DEFAULT 0.0,
    unit VARCHAR(64) NOT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP,
    UNIQUE (code)
);

CREATE TABLE IF NOT EXISTS marketplace.t_instances (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    account_id UUID NOT NULL REFERENCES master.m_accounts(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES marketplace.m_products(id) ON DELETE CASCADE,
    effectived_date TIMESTAMP DEFAULT current_timestamp,
    expired_date TIMESTAMP,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_dates CHECK (expired_date IS NULL OR expired_date >= effectived_date)
);

CREATE TABLE IF NOT EXISTS marketplace.t_instance_usages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    instance_id UUID NOT NULL REFERENCES marketplace.t_instances(id) ON DELETE CASCADE,
    period VARCHAR(16) NOT NULL,
    period_begin_date TIMESTAMP NOT NULL,
    period_end_date TIMESTAMP NOT NULL,
    usage DECIMAL(24, 12) DEFAULT NULL,
    usage_date TIMESTAMP DEFAULT current_timestamp,
    unblended_cost DECIMAL(24, 12) DEFAULT NULL,
    unblended_rate DECIMAL(24, 12) DEFAULT NULL,
    row_status enum_row_status DEFAULT 'active',
    created_by VARCHAR(64) DEFAULT 'System',
    created_date TIMESTAMP DEFAULT current_timestamp,
    updated_by VARCHAR(64),
    updated_date TIMESTAMP,
    deleted_at TIMESTAMP
);