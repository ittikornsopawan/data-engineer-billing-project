INSERT INTO master.m_account_types (code, name, group_name, row_status)
VALUES 
    ('IND', 'Individual Account', 'INDIVIDUAL', 'active'),
    ('BUS', 'Business Account', 'BUSINESS', 'active'),
    ('ENT', 'Enterprise Account', 'ENTERPRISE', 'active'),
    ('FREE', 'Free Tier Account', 'FREE_TIER', 'active');

INSERT INTO master.m_accounts (code, name, account_type_id, parent_account_id, created_by, created_date, updated_by, updated_date, row_status)
VALUES 
    ('747443860322', '่john-doe', (SELECT id FROM master.m_account_types WHERE code = 'IND'), NULL, 'System', current_timestamp, NULL, NULL, 'active'),
    ('774890550382', 'jane-smith', (SELECT id FROM master.m_account_types WHERE code = 'IND'), NULL, 'System', current_timestamp, NULL, NULL, 'active');

INSERT INTO master.m_accounts (code, name, account_type_id, parent_account_id, created_by, created_date, row_status)
VALUES 
    ('441682894486', 'Ascend Group', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), NULL, 'System', current_timestamp, 'active'),
    ('772313499959', 'True Corporation', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), NULL, 'System', current_timestamp, 'active');

INSERT INTO master.m_accounts (code, name, account_type_id, parent_account_id, created_by, created_date, row_status)
VALUES 
    ('429092326773', 'ascend-money', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'Ascend Group'), 'System', current_timestamp, 'active'),
    ('936922002519', 'ascend-commerce', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'Ascend Group'), 'System', current_timestamp, 'active'),
    ('116819170887', 'true-idc', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'Ascend Group'), 'System', current_timestamp, 'active'),
    ('655484151593', 'ascend-bit', (SELECT id FROM master.m_account_types WHERE code = 'BUS'), (SELECT id FROM master.m_accounts WHERE name = 'Ascend Group'), 'System', current_timestamp, 'active'),
    ('912577240677', 'egg-digital', (SELECT id FROM master.m_account_types WHERE code = 'BUS'), (SELECT id FROM master.m_accounts WHERE name = 'Ascend Group'), 'System', current_timestamp, 'active');

INSERT INTO master.m_accounts (code, name, account_type_id, parent_account_id, created_by, created_date, row_status)
VALUES 
    ('998795981022', 'truemove-h', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'True Corporation'), 'System', current_timestamp, 'active'),
    ('684957738202', 'true-visions', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'True Corporation'), 'System', current_timestamp, 'active'),
    ('682545126939', 'true-online', (SELECT id FROM master.m_account_types WHERE code = 'ENT'), (SELECT id FROM master.m_accounts WHERE name = 'True Corporation'), 'System', current_timestamp, 'active');

INSERT INTO master.m_discount_programs (code, name, discount_type, unit_type, min_value, max_value, start_date, end_date, created_by, created_date, row_status)
VALUES 
    ('SPP', 'Solution Provider Program', 'fixed', 'percentage', 3, 8, '2024-01-01', NULL, 'System', current_timestamp, 'active'),
    ('EDP', 'Enterprise Discount Program', 'fixed', 'percentage', 10.00, 30.00, '2024-01-01', NULL, 'System', current_timestamp, 'active');

INSERT INTO master.m_account_discount_programs (account_id, discount_program_id, min_value, is_forwarded, created_by, created_date, row_status)
VALUES 
    -- For Inidividual
    ((SELECT id FROM master.m_accounts WHERE code = '747443860322'), (SELECT id FROM master.m_discount_programs WHERE code = 'SPP'), 5.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '774890550382'), (SELECT id FROM master.m_discount_programs WHERE code = 'SPP'), 8.00, FALSE, 'System', current_timestamp, 'active'),

    -- For Ascend Group
    ((SELECT id FROM master.m_accounts WHERE code = '441682894486'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 15.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '429092326773'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 10.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '936922002519'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 10.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '116819170887'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 10.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '655484151593'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 10.00, FALSE, 'System', current_timestamp, 'active'),
    ((SELECT id FROM master.m_accounts WHERE code = '912577240677'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 10.00, FALSE, 'System', current_timestamp, 'active'),

    -- For TRUE
    ((SELECT id FROM master.m_accounts WHERE code = '772313499959'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 18.00, TRUE, 'System', current_timestamp, 'active');
    -- ((SELECT id FROM master.m_accounts WHERE code = '998795981022'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 18.00, FALSE, 'System', current_timestamp, 'active'),
    -- ((SELECT id FROM master.m_accounts WHERE code = '684957738202'),(SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 18.00, FALSE, 'System', current_timestamp, 'active'),
    -- ((SELECT id FROM master.m_accounts WHERE code = '682545126939'), (SELECT id FROM master.m_discount_programs WHERE code = 'EDP'), 18.00, FALSE, 'System', current_timestamp, 'active');

INSERT INTO project.t_projects (code, name, account_id, description, created_by, created_date, row_status)
VALUES 
    -- For Individual Accounts
    ('A1B2C3D4E5F6', 'john_doe_initiative', (SELECT id FROM master.m_accounts WHERE code = '747443860322'), 'A personalized project for John Doe focused on enhancing user experience.', 'System', current_timestamp, 'active'),
    ('G7H8I9J0K1L2', 'jane_smith_venture', (SELECT id FROM master.m_accounts WHERE code = '774890550382'), 'An innovative project led by Jane Smith to streamline service delivery.', 'System', current_timestamp, 'active'),

    -- For Ascend Group
    ('M3N4O5P6Q7R8', 'ascend_group_strategy', (SELECT id FROM master.m_accounts WHERE code = '441682894486'), 'A strategic initiative to expand Ascend Group’s market reach.', 'System', current_timestamp, 'active'),
    ('S9T0U1V2W3X4', 'ascend_money_platform', (SELECT id FROM master.m_accounts WHERE code = '429092326773'), 'Development of a digital platform for Ascend Money to enhance financial services.', 'System', current_timestamp, 'active'),
    ('Y5Z6A7B8C9D0', 'ascend_commerce_experience', (SELECT id FROM master.m_accounts WHERE code = '936922002519'), 'A project aimed at transforming the e-commerce experience for Ascend Commerce.', 'System', current_timestamp, 'active'),
    ('E1F2G3H4I5J6', 'ascend_idc_innovation', (SELECT id FROM master.m_accounts WHERE code = '116819170887'), 'Innovation initiative for Ascend IDC focusing on cloud solutions.', 'System', current_timestamp, 'active'),
    ('K2L3M4N5O6P7', 'ascend_bit_transformation', (SELECT id FROM master.m_accounts WHERE code = '655484151593'), 'Digital transformation project for Ascend Bit to improve operational efficiency.', 'System', current_timestamp, 'active'),
    ('Q8R9S0T1U2V3', 'egg_digital_revolution', (SELECT id FROM master.m_accounts WHERE code = '912577240677'), 'A revolutionary project to redefine digital marketing strategies for Egg Digital.', 'System', current_timestamp, 'active'),

    -- For True Corporation
    ('W4X5Y6Z7A8B9', 'true_corporation_growth', (SELECT id FROM master.m_accounts WHERE code = '772313499959'), 'Growth initiative for True Corporation focusing on expanding service offerings.', 'System', current_timestamp, 'active'),
    ('C0D1E2F3G4H5', 'truemove_h_engagement', (SELECT id FROM master.m_accounts WHERE code = '998795981022'), 'A project aimed at enhancing customer engagement for Truemove H.', 'System', current_timestamp, 'active'),
    ('I6J7K8L9M0N1', 'true_visions_initiative', (SELECT id FROM master.m_accounts WHERE code = '684957738202'), 'Initiative to explore innovative solutions for True Visions.', 'System', current_timestamp, 'active'),
    ('O2P3Q4R5S6T7', 'true_online_service', (SELECT id FROM master.m_accounts WHERE code = '682545126939'), 'A project to enhance online services and user experience for True Online.', 'System', current_timestamp, 'active');

-- Insert AWS service categories into product.m_product_categories with active status
INSERT INTO product.m_product_categories (code, name, description, row_status)
VALUES
    ('AWS_COMPUTE', 'Compute', 'Services that provide computing resources, such as EC2 and Lambda.', 'active'),
    ('AWS_STORAGE', 'Storage', 'Services for storing data, including S3 and EBS.', 'active'),
    ('AWS_DATABASE', 'Database', 'Managed database services like RDS, DynamoDB, and Aurora.', 'active'),
    ('AWS_NETWORKING', 'Networking', 'Services that provide networking capabilities like VPC, Route 53, and CloudFront.', 'active'),
    ('AWS_SECURITY', 'Security', 'Services focused on security such as IAM, Shield, and WAF.', 'active'),
    ('AWS_ANALYTICS', 'Analytics', 'Services for data analytics like Redshift, Athena, and EMR.', 'active');

-- Insert AWS products into product.m_products
INSERT INTO product.m_products (code, name, description, product_category_id, row_status)
VALUES
    ('AWS_EC2', 'Amazon EC2', 'Elastic Compute Cloud: Scalable virtual servers in the cloud.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_COMPUTE'), 'active'),  
    ('AWS_S3', 'Amazon S3', 'Simple Storage Service: Scalable storage for data backup and archiving.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_STORAGE'), 'active'), 
    ('AWS_RDS', 'Amazon RDS', 'Relational Database Service: Managed relational database services.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_DATABASE'), 'active'),
    ('AWS_VPC', 'Amazon VPC', 'Virtual Private Cloud: Isolated cloud resources for enhanced security.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_NETWORKING'), 'active'),
    ('AWS_IAM', 'AWS Identity and Access Management', 'Control access to AWS services and resources.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_SECURITY'), 'active'),
    ('AWS_REDSHIFT', 'Amazon Redshift', 'Fast, fully managed data warehouse for analytics.', (SELECT id FROM product.m_product_categories WHERE code = 'AWS_ANALYTICS'), 'active');

-- Insert specifications for AWS products into product.m_product_specifications
INSERT INTO product.m_product_specifications (code, name, description, product_id, specification, unit)
VALUES
    -- EC2 Specifications
    ('EC2_T2MICRO', 'Amazon EC2 T2 Micro', 'T2 Micro instance: baseline CPU performance with burst capability.', (SELECT id FROM product.m_products WHERE code = 'AWS_EC2'), '{"vCPU": 1, "memory": "1GB", "networkPerformance": "Low to Moderate", "storage": "EBS only"}', 'Instance'),
    -- S3 Specifications
    ('S3_STANDARD', 'Amazon S3 Standard', 'S3 Standard: High durability and availability storage class.', (SELECT id FROM product.m_products WHERE code = 'AWS_S3'), '{"durability": "99.999999999%", "availability": "99.99%", "storageType": "Object Storage", "regionReplication": true}', 'Storage Class'),
    -- RDS Specifications
    ('RDS_MYSQL', 'Amazon RDS MySQL', 'MySQL on RDS: Managed relational database with scalability and backup.', (SELECT id FROM product.m_products WHERE code = 'AWS_RDS'), '{"engine": "MySQL", "vCPU": 2, "memory": "8GB", "storageType": "SSD", "multiAZ": true}', 'Database Instance'),
    -- VPC Specifications
    ('VPC_DEFAULT', 'Amazon VPC Default', 'Default VPC with subnets and security groups for resource isolation.', (SELECT id FROM product.m_products WHERE code = 'AWS_VPC'), '{"maxSubnets": 6, "maxSecurityGroups": 5, "CIDR": "172.31.0.0/16"}', 'VPC'),
    -- IAM Specifications
    ('IAM_DEFAULT', 'AWS IAM Default Policy', 'Default IAM policy for user and resource access control.', (SELECT id FROM product.m_products WHERE code = 'AWS_IAM'), '{"maxUsers": "unlimited", "policiesPerUser": 10, "roleMaxSessionDuration": "12 hours"}', 'Access Control'),
    -- Redshift Specifications
    ('REDSHIFT_DS2_XLARGE', 'Amazon Redshift ds2.xlarge', 'Redshift ds2.xlarge: Dense storage node type for data warehousing.', (SELECT id FROM product.m_products WHERE code = 'AWS_REDSHIFT'), '{"vCPU": 4, "memory": "31GB", "storage": "2TB HDD", "networkPerformance": "Moderate"}', 'Node Type');

-- Insert pricing model for AWS EC2 T2 Micro
INSERT INTO product.m_pricing_model (product_id, product_spec_id, billing_cycle, pricing_unit, price_per_unit, usage_type, row_status)
VALUES
    ((SELECT id FROM product.m_products WHERE code = 'AWS_EC2'), (SELECT id FROM product.m_product_specifications WHERE code = 'EC2_T2MICRO'), 'Hourly', 'vCPU-hour', 0.012, 'Compute', 'active');

-- Insert pricing model for AWS S3 Standard
INSERT INTO product.m_pricing_model (product_id, product_spec_id, billing_cycle, pricing_unit, price_per_unit, usage_type, row_status)
VALUES
    ((SELECT id FROM product.m_products WHERE code = 'AWS_S3'), (SELECT id FROM product.m_product_specifications WHERE code = 'S3_STANDARD'), 'Monthly', 'GB-month', 0.023, 'Storage', 'active');

-- Insert pricing model for AWS RDS MySQL
INSERT INTO product.m_pricing_model (product_id, product_spec_id, billing_cycle, pricing_unit, price_per_unit, usage_type, row_status)
VALUES
    ((SELECT id FROM product.m_products WHERE code = 'AWS_RDS'), (SELECT id FROM product.m_product_specifications WHERE code = 'RDS_MYSQL'), 'Hourly', 'vCPU-hour', 0.115, 'Database', 'active');

-- Insert pricing model for AWS VPC
INSERT INTO product.m_pricing_model (product_id, product_spec_id, billing_cycle, pricing_unit, price_per_unit, usage_type, row_status)
VALUES
    ((SELECT id FROM product.m_products WHERE code = 'AWS_VPC'), (SELECT id FROM product.m_product_specifications WHERE code = 'VPC_DEFAULT'), 'Monthly', 'VPC', 0.0, 'Networking', 'active');

-- Insert pricing model for AWS IAM
INSERT INTO product.m_pricing_model (product_id, product_spec_id, billing_cycle, pricing_unit, price_per_unit, usage_type, row_status)
VALUES
    ((SELECT id FROM product.m_products WHERE code = 'AWS_IAM'), (SELECT id FROM product.m_product_specifications WHERE code = 'IAM_DEFAULT'), 'Monthly', 'User', 0.0, 'Access Control', 'active');