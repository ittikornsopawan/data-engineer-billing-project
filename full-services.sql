INSERT INTO product.m_product_categories (code, name, description, created_by, created_date, row_status)
VALUES 
    ('AWS_ANA', 'Analytics', 'Services for analyzing data and generating insights.', 'System', current_timestamp, 'active'),
    ('AWS_APP_INT', 'Application Integration', 'Integrate applications and data across various environments.', 'System', current_timestamp, 'active'),
    ('AWS_BLOCK', 'Blockchain', 'Services for building and managing blockchain networks.', 'System', current_timestamp, 'active'),
    ('AWS_BUS_APP', 'Business Applications', 'Solutions for enhancing business productivity.', 'System', current_timestamp, 'active'),
    ('AWS_FIN_MGT', 'Cloud Financial Management', 'Manage and optimize cloud spending.', 'System', current_timestamp, 'active'),
    ('AWS_COMP', 'Compute', 'Provision and manage compute resources in the cloud.', 'System', current_timestamp, 'active'),
    ('AWS_CUST_EN', 'Customer Enablement', 'Tools and resources to empower customers.', 'System', current_timestamp, 'active'),
    ('AWS_CONTAIN', 'Containers', 'Manage and deploy containerized applications.', 'System', current_timestamp, 'active'),
    ('AWS_DB', 'Databases', 'Fully managed databases for various workloads.', 'System', current_timestamp, 'active'),
    ('AWS_DEV_TOOLS', 'Developer Tools', 'Tools for developing and managing applications.', 'System', current_timestamp, 'active'),
    ('AWS_END_USER', 'End User Computing', 'Solutions for enabling end-user productivity.', 'System', current_timestamp, 'active'),
    ('AWS_FRONT_END', 'Front-end Web and Mobile', 'Build and manage front-end applications.', 'System', current_timestamp, 'active'),
    ('AWS_GAME', 'Game Tech', 'Services for building and scaling games.', 'System', current_timestamp, 'active'),
    ('AWS_IOT', 'Internet of Things (IoT)', 'Connect and manage IoT devices and applications.', 'System', current_timestamp, 'active'),
    ('AWS_ML_AI', 'Machine Learning (ML) and AI', 'Build and deploy machine learning models.', 'System', current_timestamp, 'active'),
    ('AWS_MGMT_GOV', 'Management and Governance', 'Tools for managing and governing cloud resources.', 'System', current_timestamp, 'active'),
    ('AWS_MEDIA', 'Media', 'Services for managing media workflows and content.', 'System', current_timestamp, 'active'),
    ('AWS_MIGRATE', 'Migration and Transfer', 'Tools for migrating applications and data.', 'System', current_timestamp, 'active'),
    ('AWS_NETWORK', 'Networking and Content Delivery', 'Manage networks and deliver content globally.', 'System', current_timestamp, 'active'),
    ('AWS_QUANTUM', 'Quantum Technologies', 'Explore and build quantum computing applications.', 'System', current_timestamp, 'active'),
    ('AWS_ROBOT', 'Robotics', 'Services for building and managing robotic applications.', 'System', current_timestamp, 'active'),
    ('AWS_SAT', 'Satellite', 'Services for satellite data management and processing.', 'System', current_timestamp, 'active'),
    ('AWS_SECURITY', 'Security, Identity, and Compliance', 'Manage security and compliance for AWS resources.', 'System', current_timestamp, 'active'),
    ('AWS_STORAGE', 'Storage', 'Storage solutions for various data needs.', 'System', current_timestamp, 'active');

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES 
    ('AWS_ATHENA', 'Amazon Athena', 'Interactive query service that makes it easy to analyze data in Amazon S3 using standard SQL.', (SELECT id FROM product.m_product_categories WHERE name = 'Analytics'), 'active', 'System', current_timestamp),
    ('AWS_KINESIS', 'Amazon Kinesis', 'Platform for streaming data on AWS, allowing to collect, process, and analyze real-time data.', (SELECT id FROM product.m_product_categories WHERE name = 'Analytics'), 'active', 'System', current_timestamp),
    ('AWS_GLUE', 'AWS Glue', 'Fully managed ETL service that makes it easy to prepare data for analytics.', (SELECT id FROM product.m_product_categories WHERE name = 'Analytics'), 'active', 'System', current_timestamp),
    ('AWS_QUICKSIGHT', 'Amazon QuickSight', 'Business analytics service to build visualizations, perform ad-hoc analysis, and get business insights.', (SELECT id FROM product.m_product_categories WHERE name = 'Analytics'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES 
    ('AWS_APPFLOW', 'Amazon AppFlow', 'Service to transfer data between AWS services and SaaS apps.', (SELECT id FROM product.m_product_categories WHERE name = 'Application Integration'), 'active', 'System', current_timestamp),
    ('AWS_STEP_FUNCTIONS', 'AWS Step Functions', 'Serverless orchestration service that lets you combine AWS services to create business-critical applications.', (SELECT id FROM product.m_product_categories WHERE name = 'Application Integration'), 'active', 'System', current_timestamp),
    ('AWS_EVENTBRIDGE', 'Amazon EventBridge', 'Serverless event bus that makes it easy to connect applications together using events.', (SELECT id FROM product.m_product_categories WHERE name = 'Application Integration'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES 
    ('AWS_MANAGED_BLOCKCHAIN', 'Amazon Managed Blockchain', 'Fully managed service to create and manage scalable blockchain networks.', (SELECT id FROM product.m_product_categories WHERE name = 'Blockchain'), 'active', 'System', current_timestamp);
    
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_WORKDOCS', 'Amazon WorkDocs', 'Secure content creation, storage, and sharing service.', (SELECT id FROM product.m_product_categories WHERE name = 'Business Applications'), 'active', 'System', current_timestamp),
    ('AWS_CHIME', 'Amazon Chime', 'Communications service for video conferencing, voice calls, and chat.', (SELECT id FROM product.m_product_categories WHERE name = 'Business Applications'), 'active', 'System', current_timestamp);
    
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_BUDGETS', 'AWS Budgets', 'Service that lets you set custom cost and usage budgets.', (SELECT id FROM product.m_product_categories WHERE name = 'Cloud Financial Management'), 'active', 'System', current_timestamp),
    ('AWS_COST_EXPLORER', 'AWS Cost Explorer', 'Tool that allows you to view and analyze your costs and usage.', (SELECT id FROM product.m_product_categories WHERE name = 'Cloud Financial Management'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_EC2', 'Amazon EC2', 'Scalable computing capacity in the cloud.', (SELECT id FROM product.m_product_categories WHERE name = 'Compute'), 'active', 'System', current_timestamp),
    ('AWS_LAMBDA', 'AWS Lambda', 'Run code without provisioning or managing servers.', (SELECT id FROM product.m_product_categories WHERE name = 'Compute'), 'active', 'System', current_timestamp),
    ('AWS_ECS', 'Amazon ECS', 'Highly scalable, high-performance container orchestration service.', (SELECT id FROM product.m_product_categories WHERE name = 'Compute'), 'active', 'System', current_timestamp),
    ('AWS_EKS', 'Amazon EKS', 'Managed Kubernetes service to run Kubernetes on AWS without needing to install and operate your own control plane.', (SELECT id FROM product.m_product_categories WHERE name = 'Compute'), 'active', 'System', current_timestamp);
   
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_SUPPORT', 'AWS Support', 'Comprehensive support plans for AWS customers.', (SELECT id FROM product.m_product_categories WHERE name = 'Customer Enablement'), 'active', 'System', current_timestamp);
    
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_FARGATE', 'Amazon Fargate', 'Serverless compute engine for containers that works with both Amazon ECS and EKS.', (SELECT id FROM product.m_product_categories WHERE name = 'Containers'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_RDS', 'Amazon RDS', 'Managed relational database service that makes it easy to set up, operate, and scale a relational database.', (SELECT id FROM product.m_product_categories WHERE name = 'Databases'), 'active', 'System', current_timestamp),
    ('AWS_DYNAMODB', 'Amazon DynamoDB', 'Fully managed NoSQL database service that provides fast and predictable performance.', (SELECT id FROM product.m_product_categories WHERE name = 'Databases'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_CODECOMMIT', 'AWS CodeCommit', 'Secure, scalable, and managed source control service that makes it easy for teams to host secure Git repositories.', (SELECT id FROM product.m_product_categories WHERE name = 'Developer Tools'), 'active', 'System', current_timestamp),
    ('AWS_CODEBUILD', 'AWS CodeBuild', 'Fully managed build service that compiles source code, runs tests, and produces software packages.', (SELECT id FROM product.m_product_categories WHERE name = 'Developer Tools'), 'active', 'System', current_timestamp),
    ('AWS_CODEDEPLOY', 'AWS CodeDeploy', 'Automated deployment service that helps you deploy applications to various compute services.', (SELECT id FROM product.m_product_categories WHERE name = 'Developer Tools'), 'active', 'System', current_timestamp);
     
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_WORKSPACES', 'Amazon WorkSpaces', 'Desktop as a Service (DaaS) solution that provides secure, managed Windows and Linux desktops.', (SELECT id FROM product.m_product_categories WHERE name = 'End User Computing'), 'active', 'System', current_timestamp),
    ('AWS_APPSTREAM', 'Amazon AppStream 2.0', 'Fully managed application streaming service that provides a secure way to stream desktop applications to users.', (SELECT id FROM product.m_product_categories WHERE name = 'End User Computing'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_AMPLIFY', 'AWS Amplify', 'Platform for building secure, scalable mobile and web applications.', (SELECT id FROM product.m_product_categories WHERE name = 'Front-end Web and Mobile'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_GAME_DEV', 'Amazon GameLift', 'Managed service for deploying, operating, and scaling dedicated game servers for session-based multiplayer games.', (SELECT id FROM product.m_product_categories WHERE name = 'Game Tech'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_IOT', 'AWS IoT Core', 'Managed cloud platform that lets connected devices easily and securely interact with cloud applications and other devices.', (SELECT id FROM product.m_product_categories WHERE name = 'Internet of Things (IoT)'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_SAGEMAKER', 'Amazon SageMaker', 'Fully managed service to build, train, and deploy machine learning models.', (SELECT id FROM product.m_product_categories WHERE name = 'Machine Learning (ML) and AI'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_CLOUDWATCH', 'Amazon CloudWatch', 'Monitoring and observability service for AWS resources and applications.', (SELECT id FROM product.m_product_categories WHERE name = 'Management and Governance'), 'active', 'System', current_timestamp);

INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_MEDIACONVERT', 'AWS Elemental MediaConvert', 'File-based video transcoding service with broadcast-grade features.', (SELECT id FROM product.m_product_categories WHERE name = 'Media'), 'active', 'System', current_timestamp);
       
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_DATASYNC', 'AWS DataSync', 'Online data transfer service that automates moving data between on-premises storage and AWS storage services.', (SELECT id FROM product.m_product_categories WHERE name = 'Migration and Transfer'), 'active', 'System', current_timestamp);
   
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_VPC', 'Amazon VPC', 'Virtual cloud network that enables you to provision a logically isolated section of the AWS cloud.', (SELECT id FROM product.m_product_categories WHERE name = 'Networking and Content Delivery'), 'active', 'System', current_timestamp),
    ('AWS_CLOUDFRONT', 'Amazon CloudFront', 'Fast content delivery network (CDN) service for delivering data, videos, applications, and APIs.', (SELECT id FROM product.m_product_categories WHERE name = 'Networking and Content Delivery'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_QUANTUM', 'Amazon Braket', 'Fully managed quantum computing service that helps you get started with quantum computing.', (SELECT id FROM product.m_product_categories WHERE name = 'Quantum Technologies'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_ROBOTICS', 'AWS RoboMaker', 'Development environment for robotics applications that makes it easy to develop, test, and deploy robotic applications.', (SELECT id FROM product.m_product_categories WHERE name = 'Robotics'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_IAM', 'AWS Identity and Access Management', 'Web service that helps you securely control access to AWS services and resources for your users.', (SELECT id FROM product.m_product_categories WHERE name = 'Security, Identity, and Compliance'), 'active', 'System', current_timestamp),
    ('AWS_KMS', 'AWS Key Management Service', 'Managed service that makes it easy to create and control the encryption keys used to encrypt your data.', (SELECT id FROM product.m_product_categories WHERE name = 'Security, Identity, and Compliance'), 'active', 'System', current_timestamp);
        
INSERT INTO product.m_products (code, name, description, product_category_id, row_status, created_by, created_date)
VALUES
    ('AWS_S3', 'Amazon S3', 'Object storage service that offers industry-leading scalability, data availability, security, and performance.', (SELECT id FROM product.m_product_categories WHERE name = 'Storage'), 'active', 'System', current_timestamp),
    ('AWS_EBS', 'Amazon EBS', 'Block storage service for use with Amazon EC2.', (SELECT id FROM product.m_product_categories WHERE name = 'Storage'), 'active', 'System', current_timestamp),
    ('AWS_GLACIER', 'Amazon Glacier', 'Secure, durable, and low-cost cloud storage service for data archiving and long-term backup.', (SELECT id FROM product.m_product_categories WHERE name = 'Storage'), 'active', 'System', current_timestamp);