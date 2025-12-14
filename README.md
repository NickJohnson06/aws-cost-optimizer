# AWS Cost Optimizer

Cloud-native cost analytics and optimization dashboard built on AWS.

## Tech Stack
- AWS: Lambda, API Gateway, RDS, S3, CloudFront, Cognito
- IaC: Terraform
- Backend: Node.js
- Frontend: React
- Analytics: SQL + anomaly detection (V1)

## Architecture (high-level)
EventBridge → Cost ingestion Lambda → Postgres → API Lambda → React → CloudFront

## Current Status
- [x] Repo initialized
- [ ] Terraform infrastructure
- [ ] Cost ingestion pipeline
- [ ] Dashboard MVP
- [ ] Recommendations engine