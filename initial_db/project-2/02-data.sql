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

-- Insert data for GCP product categories
insert into product.m_product_categories (code, name, description)
values
    ('COMPUTE', 'Compute Engine', 'Scalable virtual machines for applications.'),
    ('KUBERNETES', 'Kubernetes Engine', 'Managed Kubernetes services for deploying containerized applications.'),
    ('APP_ENGINE', 'App Engine', 'Platform as a service for scalable web applications.'),
    ('CLOUD_FUNCTIONS', 'Cloud Functions', 'Serverless compute for event-driven functions.'),
    ('CLOUD_RUN', 'Cloud Run', 'Managed compute platform for containers.'),
    ('STORAGE', 'Cloud Storage', 'Object storage service for storing large amounts of unstructured data.'),
    ('BIGQUERY', 'BigQuery', 'Serverless, highly scalable, and cost-effective multi-cloud data warehouse.'),
    ('SPANNER', 'Cloud Spanner', 'Scalable, multi-region, and strongly consistent database.'),
    ('SQL', 'Cloud SQL', 'Managed relational database service for MySQL, PostgreSQL, and SQL Server.'),
    ('FIRESTORE', 'Firestore', 'NoSQL document database built for automatic scaling, high performance, and ease of application development.'),
    ('PUBSUB', 'Pub/Sub', 'Messaging service for building event-driven systems and streaming analytics.'),
    ('DATAFLOW', 'Dataflow', 'Streaming analytics and batch data processing.'),
    ('DATAPROC', 'Dataproc', 'Fast, easy-to-use, fully managed cloud service for running Apache Spark and Apache Hadoop clusters.'),
    ('AI_PLATFORM', 'AI Platform', 'Suite of tools to build, deploy, and manage machine learning models.'),
    ('VISION', 'Cloud Vision API', 'Image analysis powered by machine learning.'),
    ('TRANSLATE', 'Cloud Translation API', 'Dynamic machine translation.'),
    ('SPEECH', 'Cloud Speech-to-Text', 'Speech recognition for converting audio to text.'),
    ('TEXT_TO_SPEECH', 'Cloud Text-to-Speech', 'Synthesize natural-sounding speech from text.'),
    ('RECOMMENDATIONS', 'Recommendations AI', 'Personalized recommendations for retail use cases.'),
    ('BIGTABLE', 'Bigtable', 'Fully managed, scalable NoSQL database for large analytical and operational workloads.'),
    ('MEMORSTORE', 'Memorystore', 'Managed Redis and Memcached for caching.'),
    ('DATA_CATALOG', 'Data Catalog', 'Fully managed and scalable metadata management service.'),
    ('DATAFUSION', 'Data Fusion', 'Data integration service to build and manage ETL and data movement.'),
    ('IAM', 'Identity and Access Management', 'Manage access to resources across Google Cloud.'),
    ('MONITORING', 'Cloud Monitoring', 'Real-time monitoring for Google Cloud resources and applications.'),
    ('LOGGING', 'Cloud Logging', 'Logging service for managing log data and analyzing logs.'),
    ('ERROR_REPORTING', 'Error Reporting', 'Automatically analyze errors in your cloud applications.'),
    ('DEBUGGER', 'Cloud Debugger', 'Debugging tool for identifying and fixing bugs in production.'),
    ('TRACE', 'Cloud Trace', 'Distributed tracing for performance monitoring and debugging.'),
    ('CLOUD_BUILD', 'Cloud Build', 'CI/CD platform for building, testing, and deploying code.'),
    ('ARTIFACT_REGISTRY', 'Artifact Registry', 'Repository for container images, Maven artifacts, npm packages, and more.'),
    ('SECRET_MANAGER', 'Secret Manager', 'Store, manage, and access secrets securely.'),
    ('NETWORKING', 'Networking', 'Networking products for VPC, load balancing, Cloud CDN, and more.'),
    ('IOT_CORE', 'IoT Core', 'Securely connect, manage, and ingest data from globally dispersed devices.'),
    ('ANTHOS', 'Anthos', 'Hybrid and multi-cloud solution for managing applications.'),
    ('ENDPOINTS', 'Cloud Endpoints', 'API gateway for managing APIs in Google Cloud.'),
    ('APIGEE', 'Apigee', 'API management platform for designing, securing, and analyzing APIs.');

-- Insert data for GCP products
insert into product.m_products (code, name, description, product_category_id)
values
    ('COMPUTE_ENGINE', 'Compute Engine', 'Scalable virtual machines running on Google’s infrastructure.', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('TPU', 'Tensor Processing Units', 'Accelerators optimized for machine learning workloads.', (select id from product.m_product_categories where code = 'COMPUTE')),
    ('KUBERNETES_ENGINE', 'Kubernetes Engine', 'Managed Kubernetes to deploy, manage, and scale containerized applications.', (select id from product.m_product_categories where code = 'KUBERNETES')),
    ('APP_ENGINE', 'App Engine', 'Platform-as-a-service for scalable web applications and services.', (select id from product.m_product_categories where code = 'APP_ENGINE')),
    ('CLOUD_FUNCTIONS', 'Cloud Functions', 'Serverless execution environment for building and connecting cloud services.', (select id from product.m_product_categories where code = 'CLOUD_FUNCTIONS')),
    ('CLOUD_RUN', 'Cloud Run', 'Managed service for running containerized applications without managing servers.', (select id from product.m_product_categories where code = 'CLOUD_RUN')),
    ('CLOUD_STORAGE', 'Cloud Storage', 'Object storage with global edge-caching and data lifecycle management.', (select id from product.m_product_categories where code = 'STORAGE')),
    ('BIGQUERY', 'BigQuery', 'Fully managed enterprise data warehouse for analytics at any scale.', (select id from product.m_product_categories where code = 'BIGQUERY')),
    ('CLOUD_SPANNER', 'Cloud Spanner', 'Global scale, strongly consistent managed database service.', (select id from product.m_product_categories where code = 'SPANNER')),
    ('CLOUD_SQL', 'Cloud SQL', 'Managed MySQL, PostgreSQL, and SQL Server database services.', (select id from product.m_product_categories where code = 'SQL')),
    ('FIRESTORE', 'Cloud Firestore', 'Flexible, scalable NoSQL cloud database to store, sync, and query data.', (select id from product.m_product_categories where code = 'FIRESTORE')),
    ('PUBSUB', 'Pub/Sub', 'Real-time messaging service for event-driven applications and analytics.', (select id from product.m_product_categories where code = 'PUBSUB')),
    ('DATAFLOW', 'Dataflow', 'Stream and batch data processing service.', (select id from product.m_product_categories where code = 'DATAFLOW')),
    ('DATAPROC', 'Dataproc', 'Managed Apache Hadoop and Spark clusters in the cloud.', (select id from product.m_product_categories where code = 'DATAPROC')),
    ('AI_PLATFORM', 'AI Platform', 'Managed services for training, tuning, and deploying machine learning models.', (select id from product.m_product_categories where code = 'AI_PLATFORM')),
    ('VISION_API', 'Vision API', 'Image analysis service with powerful pre-trained machine learning models.', (select id from product.m_product_categories where code = 'VISION')),
    ('TRANSLATE_API', 'Translation API', 'Dynamic translation for over 100 languages.', (select id from product.m_product_categories where code = 'TRANSLATE')),
    ('SPEECH_TO_TEXT', 'Speech-to-Text', 'Convert audio to text with machine learning-powered transcription.', (select id from product.m_product_categories where code = 'SPEECH')),
    ('TEXT_TO_SPEECH', 'Text-to-Speech', 'Convert text into natural-sounding speech using machine learning.', (select id from product.m_product_categories where code = 'TEXT_TO_SPEECH')),
    ('RECOMMENDATIONS_AI', 'Recommendations AI', 'Machine learning-powered personalized product recommendations.', (select id from product.m_product_categories where code = 'RECOMMENDATIONS')),
    ('BIGTABLE', 'Bigtable', 'Scalable NoSQL database suited for analytics and operational workloads.', (select id from product.m_product_categories where code = 'BIGTABLE')),
    ('MEMORSTORE', 'Memorystore', 'Managed Redis and Memcached for caching.', (select id from product.m_product_categories where code = 'MEMORSTORE')),
    ('DATA_CATALOG', 'Data Catalog', 'Metadata management service for discovering and managing data assets.', (select id from product.m_product_categories where code = 'DATA_CATALOG')),
    ('DATA_FUSION', 'Data Fusion', 'Managed data integration service for building ETL pipelines.', (select id from product.m_product_categories where code = 'DATAFUSION')),
    ('IAM', 'Identity and Access Management', 'Manage roles and permissions for cloud resources.', (select id from product.m_product_categories where code = 'IAM')),
    ('CLOUD_MONITORING', 'Cloud Monitoring', 'Real-time monitoring, logging, and metrics for cloud applications.', (select id from product.m_product_categories where code = 'MONITORING')),
    ('CLOUD_LOGGING', 'Cloud Logging', 'Centralized log management and analysis.', (select id from product.m_product_categories where code = 'LOGGING')),
    ('ERROR_REPORTING', 'Error Reporting', 'Automatic error reporting and tracking for cloud applications.', (select id from product.m_product_categories where code = 'ERROR_REPORTING')),
    ('CLOUD_DEBUGGER', 'Cloud Debugger', 'Real-time debugging for identifying and fixing issues in production.', (select id from product.m_product_categories where code = 'DEBUGGER')),
    ('CLOUD_TRACE', 'Cloud Trace', 'Distributed tracing for performance monitoring of applications.', (select id from product.m_product_categories where code = 'TRACE')),
    ('CLOUD_BUILD', 'Cloud Build', 'Continuous integration and delivery platform for Google Cloud.', (select id from product.m_product_categories where code = 'CLOUD_BUILD')),
    ('ARTIFACT_REGISTRY', 'Artifact Registry', 'Container image and artifact repository service.', (select id from product.m_product_categories where code = 'ARTIFACT_REGISTRY')),
    ('SECRET_MANAGER', 'Secret Manager', 'Securely store and manage sensitive information.', (select id from product.m_product_categories where code = 'SECRET_MANAGER')),
    ('VPC', 'Virtual Private Cloud', 'Isolated virtual network within Google Cloud.', (select id from product.m_product_categories where code = 'NETWORKING')),
    ('LOAD_BALANCING', 'Cloud Load Balancing', 'Global load balancing service for distributing traffic.', (select id from product.m_product_categories where code = 'NETWORKING')),
    ('CLOUD_CDN', 'Cloud CDN', 'Content Delivery Network for low-latency content delivery.', (select id from product.m_product_categories where code = 'NETWORKING')),
    ('IOT_CORE', 'IoT Core', 'Connect, manage, and ingest data from IoT devices.', (select id from product.m_product_categories where code = 'IOT_CORE')),
    ('ANTHOS', 'Anthos', 'Application management for hybrid and multi-cloud environments.', (select id from product.m_product_categories where code = 'ANTHOS')),
    ('CLOUD_ENDPOINTS', 'Cloud Endpoints', 'API management gateway for secure API management.', (select id from product.m_product_categories where code = 'ENDPOINTS')),
    ('APIGEE', 'Apigee API Management', 'Design, secure, deploy, and analyze APIs.', (select id from product.m_product_categories where code = 'APIGEE'));