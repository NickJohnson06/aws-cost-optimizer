# AWS Cost Optimizer

## Overview
AWS Cost Optimizer is a comprehensive cloud-native cost analytics and optimization dashboard built on AWS. It is designed to ingest, process, and visualize AWS Cost and Usage Reports (CUR) to provide actionable insights into cloud spending.

The project leverages a fully serverless architecture for its backend and data processing pipeline, utilizing event-driven patterns to handle cost reports as they are delivered. The frontend is a modern single-page application (SPA) distributed globally via a Content Delivery Network (CDN). All infrastructure components are provisioned and managed using Terraform.

AWS Cost Optimizer focuses on delivering visibility into cloud costs through automated data ingestion, structured storage for complex querying, and a user-friendly interface for tracking spending trends and anomalies.

## Architecture

### High-Level Design
- **Event-Driven Ingestion:** Automated processing of CUR files triggered by S3 events via EventBridge.
- **Serverless Data Pipeline:** Lambda functions for parsing and inserting billing data.
- **Relational Data Store:** Amazon RDS (PostgreSQL) for structured data storage and complex analytics.
- **Serverless API:** RESTful API built with Amazon API Gateway and Lambda (Node.js).
- **Secure Frontend:** React application hosted on S3 and served via CloudFront.
- **Authentication:** Amazon Cognito for secure user identity and access management.
- **Infrastructure as Code:** Complete environment management with Terraform.

### Data Flow
EventBridge → Cost Ingestion Lambda → Postgres (RDS) → API Lambda → React Framework → CloudFront Distribution

## Objectives
- Automate the ingestion and processing of AWS Cost and Usage Reports.
- Store detailed billing line items in a query-optimized relational database.
- Detect spending anomalies using SQL-based analytics and statistical methods.
- Visualize cost trends and resource usage via an interactive dashboard.
- Implement a secure, scalable, and cost-effective serverless architecture.
- Manage all infrastructure lifecycle steps using Terraform.
- Provide a foundation for advanced cost optimization recommendations.

## Technology Stack

### Infrastructure & Cloud Services
- **Compute:** AWS Lambda
- **Networking & Content Delivery:** Amazon API Gateway, Amazon CloudFront
- **Storage & Database:** Amazon S3, Amazon RDS (PostgreSQL)
- **Security & Identity:** Amazon Cognito, AWS IAM
- **Integration:** Amazon EventBridge
- **IaC:** Terraform

### Application Components
- **Backend Runtime:** Node.js
- **Frontend Framework:** React
- **Analytics Engine:** SQL + Custom Anomaly Detection (V1)

## Key Features

### Data Engineering
- **Automated Ingestion:** Real-time triggering of ingestion processes upon new report delivery.
- **Data Normalization:** Parsing and structuring of raw CSV/Parquet cost data for relational storage.

### API & Backend
- **Serverless Architecture:** Highly scalable and cost-efficient backend execution.
- **Secure Endpoints:** API Gateway integration with Cognito Authorizers.
- **Optimized Queries:** SQL-based aggregation for fast dashboard loading.

### Frontend Visualization
- **Interactive Dashboard:** Graphical representation of daily and monthly spend.
- **Filtering & Drill-down:** Capability to view costs by service, region, or tag.

### Infrastructure as Code
- **Modular Design:** Separation of concerns in Terraform configurations (VPC, Compute, Database).
- **State Management:** Remote state storage with locking for team collaboration.

## Project Structure
```
├── backend/         # Lambda functions (Ingestion, API) and business logic
├── frontend/        # React application source code and public assets
├── infra/           # Terraform infrastructure modules and environments
├── docs/            # Architecture diagrams and supplementary documentation
└── README.md        # Project documentation
```

## Deployment Instructions
From the `infra` directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Current Status
- [x] Repo initialized
- [ ] Terraform infrastructure
- [ ] Cost ingestion pipeline
- [ ] Recommendations engine