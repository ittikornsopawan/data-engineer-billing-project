do $$ 
begin
    create type enum_row_status as enum ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'ARCHIVED', 'DELETED');
exception
    when duplicate_object then null;
end $$;

create schema if not exists account;

create table if not exists account.m_accounts
(
	id uuid default gen_random_uuid() primary key,
	code varchar(32) not null,
	name varchar(128) not null,
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create table if not exists account.t_reseller_accounts
(
    id uuid default gen_random_uuid() primary key,
    account_id uuid not null references account.m_accounts(id),
    reseller_margin_percentage decimal(5,2) default 0,
    expired_date timestamp,
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create table if not exists account.t_billing_accounts
(
	id uuid default gen_random_uuid() primary key,
    billing_type varchar(16) default check ('BILLING', 'RESELLER'),
	billing_account_id uuid not null references account.m_accounts(id),
    account_id uuid not null references account.m_accounts(id),
    effectived_date timestamp not null default current_timestamp,
    discount_percentage decimal(5,2) default 0,
    expired_date timestamp,
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create schema if not exists product;

create table if not exists product.m_product_categories
(
	id uuid default gen_random_uuid() primary key,
	code varchar(32) not null,
	name varchar(128) not null,
	description text,
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp,
    deleted_at timestamp
);

create table if not exists product.m_products
(
	id uuid default gen_random_uuid() primary key,
	code varchar(64) not null,
	name varchar(512) not null,
	description text,
	product_category_id uuid not null references product.m_product_categories(id),
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create table if not exists product.m_product_specifications
(
	id uuid default gen_random_uuid() primary key,
	code varchar(32) not null,
	specification jsonb not null,
    product_id  uuid not null references product.m_products(id),
	pricing_model_id uuid not null references product.m_product_pricing_models(id),
	unit varchar(128) not null,
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create table if not exists product.t_product_specification_pricing
(
	id uuid default gen_random_uuid() primary key,
	product_specification_id uuid not null references product.m_product_specifications(id),
    term int not null,
    duration varchar(8) default 'HOURLY' check ('HOURLY', 'DAILY', 'MONTHLY', 'ANNUALLY'),
    usage decimal(24, 12) not null default 0,
	unit_price decimal(24, 12) not null default 0,
    unit varchar(64) not null,
    pricing_type vaechar(8) default 'FIXED' check ('FIXED', 'TIER'),
    tiers jsonb default null,
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create schema if not exists project;

create table if not exists project.t_projects
(
	id uuid default gen_random_uuid() primary key,
	code varchar(32) not null,
	name varchar(128) not null,
    description text,
    account_id uuid not null references account.m_accounts(id),
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create table if not exists project.t_project_items
(
	id uuid default gen_random_uuid() primary key,
	code varchar(32) not null,
    project_id uuid not null references project.t_projects(id),
    product_id uuid not null references project.m_products(id),
    product_specification_id uuid not null references project.m_product_specifications(id),
    product_specification_pricing_id uuid not null references project.t_product_specification_pricing(id),
    effectived_date timestamp default current_timestamp,
    expired_date timestamp,
    row_status enum_row_status default 'ACTIVE',
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp
);

create schema if not exists transaction;

create table if not exists transaction.t_product_usages
(
    id uuid default gen_random_uuid() primary key,
    project_item_id uuid not null references project.t_project_items(id),
    period varchar(8) not null,
    usage_start_datetime timestamp not null,
    usage_end_datetime timestamp not null,
    usage_amount decimal(24, 12) not null default 0,
    cost decimal(24, 12) not null default 0,
    reseller_margin decimal(24, 12) not null default 0,
    created_by varchar(64) default 'SYSTEM',
    created_date timestamp default current_timestamp
)