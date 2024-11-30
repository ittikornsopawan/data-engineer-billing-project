insert into account.m_accounts(code, name)
values
    ('A3B5C8-D9E2F1-G4H7J0-K1L6M9', 'a-group'),
    ('P7Q3R8-S1T2U4-V9W6X5-Y2Z8A3', 'a-commerce'),
    ('M6N9O5-P1Q3R7-A8S2T4-U9V0W5', 't-group'),
    ('X1Y7Z3-W8A2B5-C9D4E6-F1G9H3', 't-online');

insert into account.t_reseller_accounts(account_id, reseller_margin_percentage, expired_date)
values
    ((select id from account.m_accounts where code = 'A3B5C8-D9E2F1-G4H7J0-K1L6M9'), 40.00, current_timestamp + interval '1 year');

insert into account.t_billing_accounts(billing_type, billing_account_id, account_id, effectived_date, discount_percentage)
values
    ('RESELLER', (select id from account.m_accounts where code = 'A3B5C8-D9E2F1-G4H7J0-K1L6M9'), (select id from account.m_accounts where code = 'A3B5C8-D9E2F1-G4H7J0-K1L6M9'), current_timestamp, 40),
    ('RESELLER', (select id from account.m_accounts where code = 'A3B5C8-D9E2F1-G4H7J0-K1L6M9'), (select id from account.m_accounts where code = 'P7Q3R8-S1T2U4-V9W6X5-Y2Z8A3'), current_timestamp, 20),
    ('RESELLER', (select id from account.m_accounts where code = 'M6N9O5-P1Q3R7-A8S2T4-U9V0W5'), (select id from account.m_accounts where code = 'M6N9O5-P1Q3R7-A8S2T4-U9V0W5'), current_timestamp, 0),
    ('RESELLER', (select id from account.m_accounts where code = 'M6N9O5-P1Q3R7-A8S2T4-U9V0W5'), (select id from account.m_accounts where code = 'X1Y7Z3-W8A2B5-C9D4E6-F1G9H3'), current_timestamp, 0);

insert into product.m_product_categories (code, name, description)
values
    ('COMPUTE', 'Compute Services', 'GCP compute services such as Virtual Machines, Kubernetes, and Cloud Functions'),
    ('STORAGE', 'Storage Services', 'GCP storage services such as Cloud Storage, BigQuery, Cloud SQL'),
    ('NETWORK', 'Networking Services', 'GCP networking services such as VPC, Load Balancing, Cloud CDN'),
    ('ML', 'Machine Learning Services', 'GCP services for Machine Learning and AI such as AutoML, Vertex AI'),
    ('SECURITY', 'Security Services', 'GCP security services such as Identity and Access Management (IAM), Cloud Armor'),
    ('BIGDATA', 'Big Data Services', 'GCP services for Big Data such as BigQuery, Dataflow, Dataproc'),
    ('IOT', 'IoT Services', 'GCP services for Internet of Things such as IoT Core, Edge TPU'),
    ('API', 'API Management', 'API management services such as Apigee'),
    ('SERVERLESS', 'Serverless', 'Serverless services such as Cloud Functions, App Engine'),
    ('CLOUDOPS', 'Cloud Operations', 'Cloud operation services such as Cloud Monitoring, Cloud Logging');

insert into product.m_products (code, name, description, product_category_id)
values
    ('COMPUTE-ENGINE', 'Google Compute Engine', 'Virtual Machines for cloud computation on GCP', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('GKE', 'Google Kubernetes Engine', 'Managed Kubernetes clusters for deploying applications on GCP', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('CLOUD-FUNCTIONS', 'Google Cloud Functions', 'Serverless compute service for running code without managing servers on GCP', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('CLOUD-STORAGE', 'Google Cloud Storage', 'Flexible, scalable cloud storage service on GCP', (select id from product.m_product_categories where code = 'STORAGE')), 
    ('BIGQUERY', 'BigQuery', 'Big Data analytics service for handling large-scale data analysis on GCP', 'BIGDATA'),
    ('CLOUD-SQL', 'Cloud SQL', 'SQL database service supporting MySQL, PostgreSQL, and SQL Server on GCP', (select id from product.m_product_categories where code = 'STORAGE')),
    ('VERTEX-AI', 'Vertex AI', 'Machine learning service for building and managing AI models on GCP', 'ML'),
    ('APIGEE', 'Apigee', 'API management platform for designing, securing, and analyzing APIs on GCP', 'API'),
    ('VPC', 'Google VPC', 'Virtual Private Cloud networking for managing your network infrastructure on GCP', 'NETWORK'),
    ('IAM', 'Identity and Access Management', 'Manage user identities and access permissions on GCP', (select id from product.m_product_categories where code = 'SECURITY')),
    ('CLOUD-FUNCTIONS-GO', 'Cloud Functions (Go)', 'Cloud Functions for Go language on GCP', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('CLOUD-KEY-MANAGEMENT', 'Cloud Key Management', 'Service for managing encryption keys for your data on GCP', (select id from product.m_product_categories where code = 'SECURITY')),
    ('TENSORFLOW', 'TensorFlow', 'Open-source software library for machine learning used with GCP services', 'ML'),
    ('FIREBASE', 'Firebase', 'Platform for building mobile and web applications with integrated backend services', 'SERVERLESS'),
    ('PRIVATE-CLOUD-SAP', 'Private Cloud for SAP', 'Run SAP applications on Google Cloud with optimized performance and security', (select id from product.m_product_categories where code = 'STORAGE')),
    ('CLOUD-DATASTORE', 'Cloud Datastore', 'NoSQL document database for automatic scaling and high availability', (select id from product.m_product_categories where code = 'STORAGE')),
    ('SECRET-MANAGER', 'Secret Manager', 'Service for storing and managing sensitive information such as API keys and passwords', (select id from product.m_product_categories where code = 'SECURITY')),
    ('PUBSUB', 'Cloud Pub/Sub', 'Real-time messaging service for event-driven systems', 'API'),
    ('BIGQUERY-ML', 'BigQuery ML', 'Machine learning integrated with BigQuery for analyzing and predicting data', 'ML'),
    ('CLOUD-FPGA', 'Cloud FPGA', 'Accelerated computing with FPGAs for specialized workloads', (select id from product.m_product_categories where code = 'COMPUTE'));