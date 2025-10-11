# AWS Three-Tier Web App with Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.6%2B-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)

This repository delivers an opinionated, production-ready AWS deployment of a three-tier web application. Provision the infrastructure with Terraform, ship containers with GitHub Actions, and serve your React/Express sample workloads via AWS managed services—all from this repo.

## What You Get

- A highly-available VPC with public/private subnets, routing, and security boundaries
- Application Load Balancer fronting an ECS Fargate service that runs the API container
- Amazon RDS for PostgreSQL with credentials stored in AWS Secrets Manager
- Amazon ECR repository for versioned container images
- Amazon S3 bucket + CloudFront distribution for a static web front-end
- GitHub Actions workflows wired via OIDC to manage infrastructure, app deployments, and static assets end-to-end

## Tech Stack

- **Infrastructure as Code:** Terraform 1.6+, remote state in S3 with DynamoDB state locking
- **AWS Services:** VPC, ALB, ECS Fargate, RDS PostgreSQL, Secrets Manager, ECR, S3, CloudFront, IAM (OIDC federation)
- **Application Layer:** Node.js 18, Express.js API, static web front-end (React-ready structure), Docker
- **CI/CD:** GitHub Actions pipelines for Terraform plans/applies, container builds, and static site sync + CloudFront invalidation

## Architecture Overview

```mermaid
flowchart LR
  DevRepo["GitHub Repo<br/>(dev & main branches)"] --> GA[GitHub Actions Workflows]
  GA -->|OIDC assume role| IAM[IAM Federated Roles]
  GA -->|Terraform apply| TF[IaC Provisioning]
  GA -->|Build & push| ECR[Amazon ECR]
  GA -->|Sync static site| S3[Amazon S3 Static Site Bucket]
  TF --> VPC[VPC & Subnets]
  TF --> ALB[Application Load Balancer]
  TF --> ECSCluster[ECS Cluster (Fargate)]
  TF --> RDS[(Amazon RDS PostgreSQL)]
  TF --> Secrets[AWS Secrets Manager]
  TF --> CF[Amazon CloudFront Distribution]
  VPC --> ALB
  ALB --> ECSService[ECS Service Tasks]
  ECSService -->|Fetch secrets| Secrets
  ECSService -->|Connects| RDS
  ECR --> ECSService
  Users[End Users] -->|HTTPS| CF
  CF -->|Origin access| S3
  Users -->|API calls| ALB
```

## Repository Layout

```
aws-three-tier-webapp-terraform/
├─ app/                     # Express.js sample API packaged for ECS
├─ web/                     # Static web front-end served via CloudFront
├─ infra/                   # Terraform code (root module + environment configs)
├─ .github/workflows/       # CI/CD pipelines
├─ scripts/                 # Utility scripts (including this bootstrap generator)
└─ supporting files         # Linting, formatting, and automation configs
```

## Getting Started

### Prerequisites

- Terraform >= 1.5
- AWS CLI configured with credentials that can provision IAM, VPC, ECS, RDS, ECR, S3, and CloudFront
- Docker and Node.js 18.x (for local app builds/tests)
- `pre-commit` (optional but recommended)

### Initialise Environment

1. Copy the repository and review the environment-specific settings in `infra/envs/dev/terraform.tfvars` (and `prod` as needed).
2. Configure the Terraform backend (S3 bucket + DynamoDB table) referenced in `infra/envs/<env>/backend.hcl`.
3. Initialise Terraform for the desired environment:

   ```bash
   make init ENV=dev
   ```

4. Format, validate, and plan:

   ```bash
   make fmt
   make validate
   make plan ENV=dev
   ```

5. Apply when ready:

   ```bash
   make apply ENV=dev
   ```

### Bootstrapping AWS OIDC for GitHub Actions

The `infra/modules/bootstrap` module provisions the AWS IAM OpenID Connect provider for GitHub plus three federated roles:

- `terraform` – full infrastructure lifecycle
- `app-deploy` – pushes images to ECR and updates the ECS service
- `web-deploy` – syncs assets to S3 and invalidates CloudFront caches

Update `infra/variables.tf` with the GitHub repository slug (`owner/repo`). Enable the bootstrap module by setting `enable_bootstrap = true` inside the relevant `terraform.tfvars`. Apply once to establish the OIDC trust, then disable if you prefer to keep bootstrap resources separate.

After the bootstrap run, add the role ARNs as `AWS_ROLE_TO_ASSUME` secrets inside your GitHub repository so the workflows can assume the correct role per job.

### CI/CD Pipelines

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `infra-dev.yml` | Push/PR to `dev/**` | Terraform plan/apply against the dev environment |
| `infra-prod.yml` | Manual dispatch + protected branches | Terraform plan/apply against prod |
| `app-deploy.yml` | Push to `app/**` or release tags | Build + push Docker image to ECR and redeploy ECS |
| `web-deploy.yml` | Push to `web/**` | Sync static site to S3 and invalidate CloudFront |

### Required GitHub Secrets

| Secret | Purpose |
|--------|---------|
| `AWS_TERRAFORM_ROLE_ARN_DEV` | IAM role for dev Terraform jobs (from bootstrap output) |
| `AWS_TERRAFORM_ROLE_ARN_PROD` | IAM role for prod Terraform jobs |
| `AWS_APP_DEPLOY_ROLE_ARN_DEV` | IAM role for ECS deployments to dev |
| `AWS_APP_DEPLOY_ROLE_ARN_PROD` | IAM role for ECS deployments to prod |
| `AWS_WEB_DEPLOY_ROLE_ARN_DEV` | IAM role for static site deploys to dev |
| `AWS_WEB_DEPLOY_ROLE_ARN_PROD` | IAM role for static site deploys to prod |
| `STATIC_SITE_BUCKET_DEV` | Name of the S3 bucket for the dev static site (`terraform output -raw static_site_bucket`) |
| `STATIC_SITE_BUCKET_PROD` | Name of the S3 bucket for the prod static site |
| `CLOUDFRONT_DISTRIBUTION_ID_DEV` | CloudFront distribution ID for dev (`terraform output -raw static_site_distribution_id`) |
| `CLOUDFRONT_DISTRIBUTION_ID_PROD` | CloudFront distribution ID for prod |

Store these secrets at the repository level. The bucket and distribution identifiers are emitted as Terraform outputs after the first apply—copy them into GitHub so the web deployment workflow can push assets and invalidate caches.

### Local Development

- `make app-build` builds the sample API Docker image locally.
- `make web-preview` serves the static front-end via Python’s simple HTTP server for quick iteration.
- `pre-commit install` sets up automatic Terraform formatting, validation, and linting before every commit.

### Cleaning Up

Destroy the environment when you are finished:

```bash
make destroy ENV=dev
```

Ensure you remove the remote state S3 bucket and DynamoDB table manually if they are dedicated to this project.
