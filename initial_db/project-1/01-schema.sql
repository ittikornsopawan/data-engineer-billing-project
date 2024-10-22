create schema if not exists master;

create table if not exists master.m_account_types
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	group_name varchar(128) not null,
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create table if not exists master.m_accounts
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	account_type_id uuid not null references master.m_account_types(id),
	parent_account_id uuid references master.m_accounts(id),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create schema if not exists product;

create table if not exists product.m_product_categories
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	description text,
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create table if not exists product.m_products
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	description text,
	product_category_id uuid not null references product.m_product_categories(id),
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create table if not exists product.m_sub_products
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	description text,
	product_id uuid not null references product.m_products(id),
	specification jsonb not null,
	unit varchar(64) not null,
	effectived_date timestamp default current_timestamp,
	expired_date timestamp default null,
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create table if not exists product.m_pricing_model
(
	id uuid default gen_random_uuid() primary key,
	product_id uuid not null references product.m_products(id),
	sub_product_id uuid not null references product.m_sub_products(id),
	billing_cycle varchar(64) not null,
	pricing_unit varchar(128) not null,
	price_per_unit decimal(18, 12) default 0.0,
	tier jsonb,
	usage_value decimal(24,12) default null,
	usage_type varchar(64) not null,
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create schema if not exists transaction;

create table if not exists transaction.t_instances
(
	id uuid default gen_random_uuid() primary key,
	code varchar(16) not null,
	name varchar(128) not null,
	account_id uuid not null references master.m_accounts(id),
	product_id uuid not null references product.m_products(id),
	sub_product_id uuid not null references product.m_sub_products(id),
	pricing_model_id uuid not null references product.m_pricing_model(id),
	effectived_date timestamp default current_timestamp,
	expired_date timestamp default null,
	row_status varchar(64),
	created_by varchar(64) default 'System',
	created_date timestamp default current_timestamp,
	updated_by varchar(64),
	updated_date timestamp 
);

create table if not exists transaction.t_instance_usages
(
	id uuid default gen_random_uuid() primary key,
	instance_id uuid not null references transaction.t_instances(id),
	pricing_model_id uuid not null references product.m_pricing_model(id),
	period varchar(16) not null,
    period_begin_date timestamp not null,
    period_end_date timestamp not null, 
	usage decimal(24,12) default null,
	usage_date timestamp default current_timestamp,
    unblended_cost decimal(24,12) default null,
    unblended_rate decimal(24,12) default null,
    row_status varchar(64),
    created_by varchar(64) default 'System',
    created_date timestamp default current_timestamp,
    updated_by varchar(64),
    updated_date timestamp  
);




















