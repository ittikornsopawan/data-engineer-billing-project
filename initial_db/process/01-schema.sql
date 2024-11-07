CREATE TABLE IF NOT EXISTS t_billing (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    period varchar(7),
    payer_account_id varchar(12),
    payer_account_name varchar(255),
    usage_account_id varchar(12),
    usage_account_name varchar(255),
    total_usage_cost decimal(24, 12),
    total_tax decimal(24, 12),
    total_discount_program decimal(24, 12),
    total_discounted_cost decimal(24, 12),
    total_marketplace decimal(24, 12),
    total_cost decimal(24, 12),
    total_expenditure decimal(24, 12),
    created_date timestamp DEFAULT current_timestamp,
    created_by varchar(64) DEFAULT 'system',
    CONSTRAINT unique_usage_account_period_created_date UNIQUE (usage_account_id, period, created_date)
);