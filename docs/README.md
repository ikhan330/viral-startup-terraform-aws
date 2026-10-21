# Viral Startup — AWS Serverless Web Application

A portfolio project demonstrating how to deploy a static website and serverless API on AWS using Terraform.

> **Accuracy note:** This repository contains Terraform source and project files. Before describing any component as production-ready, compare the configuration and live AWS resources with the architecture diagram. Optional/reference items such as Route 53, a second NAT Gateway, Multi-AZ RDS, SNS, and CloudTrail integrations must only be claimed as deployed if verified.

## Architecture

![Viral Startup AWS architecture](docs/aws-architecture.png)

### Request flows

**Static frontend**
1. A user opens the website over HTTPS.
2. Amazon CloudFront distributes and caches static content.
3. CloudFront retrieves the frontend assets from the Amazon S3 origin.

**API and data**
1. The browser sends HTTPS requests to Amazon API Gateway.
2. API Gateway invokes the Python AWS Lambda function.
3. The Lambda function connects to PostgreSQL on Amazon RDS.
4. The Lambda function uses its VPC networking and NAT egress when it needs outbound internet access, such as reaching an external package or API endpoint. NAT does not provide inbound access to the Lambda function.

## AWS services and tools

| Service/tool | Purpose |
|---|---|
| Amazon S3 | Stores static website assets |
| Amazon CloudFront | HTTPS delivery and content caching |
| Amazon API Gateway | HTTPS REST API endpoint |
| AWS Lambda | Python backend logic |
| Amazon RDS for PostgreSQL | Relational application data |
| Amazon VPC and subnets | Network isolation for backend/data resources |
| NAT Gateway | Outbound internet access from private subnets, when required |
| Security Groups / IAM | Network access control and permissions |
| Terraform | Infrastructure as Code |
| Git / GitHub | Version control and portfolio evidence |

Only list services as **deployed** after confirming them in the Terraform configuration and AWS console/CLI.

## Repository layout

```text
.
├── api_gateway.tf
├── cloudfront.tf
├── cloudfront_invalidation.tf
├── lambda.tf
├── main.tf
├── nat.tf
├── outputs.tf
├── providers.tf
├── s3.tf
├── variables.tf
├── versions.tf
├── terraform.tfvars.example
├── .terraform.lock.hcl
└── viral-startup-site-bundle/
    ├── README.md
    ├── docs/
    │   └── DEPLOYMENT.md
    ├── lambda-function/
    │   ├── handler.py
    │   ├── requirements.txt
    │   ├── build_lambda.ps1
    │   └── build_lambda.sh
    └── s3-static-site/
        ├── index.html
        ├── app.js
        ├── config.js
        └── styles.css
```

The exact layout may change as the project evolves. Do not commit Terraform state, local variable files, credentials, private keys, or generated deployment ZIPs.

## Prerequisites

- Git
- Terraform CLI compatible with `versions.tf`
- AWS CLI configured with a dedicated IAM identity
- An AWS account with permissions required by the Terraform resources
- Python version compatible with the Lambda runtime, plus the dependencies listed in `requirements.txt`
- A configured AWS region (the current project configuration uses `ap-south-1`)

## Configure safely

1. Clone the repository.
2. Review `versions.tf`, providers, variables, and all Terraform resources.
3. Create your local variable file from the example:

   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

4. Edit `terraform.tfvars` locally with the required values. Use a strong, unique database password. Do not commit this file.
5. Verify AWS identity and region:

   ```powershell
   aws sts get-caller-identity
   aws configure get region
   ```

## Terraform workflow

Run these commands from the Terraform root directory:

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=tfplan
```

Review the plan carefully before applying:

```powershell
terraform show tfplan
terraform apply tfplan
```

Destroying resources can permanently delete data and may not be reversible. Only use `terraform destroy` when you intentionally want to remove the environment and have protected any required data.

## Security checklist

- [ ] `terraform.tfvars` and all state/plan files are ignored by Git.
- [ ] No AWS access keys, tokens, passwords, private keys, or production data are committed.
- [ ] The database is not publicly accessible unless there is a documented, approved reason.
- [ ] RDS ingress is restricted to the application security group and required database port.
- [ ] Lambda has only the IAM permissions it needs.
- [ ] S3 origin access is restricted appropriately; public bucket access is not enabled unnecessarily.
- [ ] API inputs are validated and errors do not disclose credentials or internal details.
- [ ] CloudWatch logs/alarms and audit logging are configured and verified if claimed.
- [ ] Database backups and restore procedures are tested.
- [ ] NAT Gateway and other billable resources are reviewed when not in use.

## Validation and evidence

Capture evidence only after running the checks:

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan
git status --short
git check-ignore -v terraform.tfvars
```

Recommended portfolio evidence:
- Architecture diagram
- Terraform validation output
- Redacted AWS resource screenshots
- API health check and successful API response
- Frontend screenshot
- CloudWatch logs/metrics (if configured)
- A troubleshooting/RCA note describing one real issue and its verified root cause

Never publish screenshots containing account IDs when unnecessary, public IPs that should remain private, credentials, tokens, or personal information.

## Cost awareness

NAT Gateways, RDS, data transfer, and other resources can incur charges. Check the AWS Billing console and remove unused resources safely. Before deleting infrastructure, confirm whether any database data must be retained.

## Current project status

Update this section based on actual validation:
- [ ] Terraform formatting check passed
- [ ] Terraform validation passed
- [ ] Terraform plan reviewed
- [ ] Security audit completed
- [ ] Frontend smoke test completed
- [ ] API smoke test completed
- [ ] Database connectivity verified
- [ ] Monitoring and backup/restore evidence captured
- [ ] Cost review completed

## Interview summary

“I built a static frontend delivered through CloudFront and S3, with API requests handled by API Gateway and a Python Lambda backend. The backend stores relational data in PostgreSQL on RDS. I use Terraform to define and version-control the infrastructure. I validate the deployment with Terraform checks and application smoke tests, restrict access through IAM and network controls, and document security, cost, and troubleshooting evidence.”

Only make claims that match the resources and tests you have personally verified.
