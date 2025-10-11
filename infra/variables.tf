variable "project_name" {
  description = "Project name used for tagging and resource naming."
  type        = string
  default     = "three-tier-webapp"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability zones to spread public/private subnets across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "webapp"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "webapp"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15.4"
}

variable "enable_bootstrap" {
  description = "Whether to create the AWS OIDC bootstrap resources."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository in owner/name format used for OIDC trust."
  type        = string
  default     = "your-org/aws-three-tier-webapp-terraform"
}

variable "web_domain_name" {
  description = "Optional custom domain for CloudFront. Leave null to use the default distribution domain."
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN (in us-east-1) to associate with CloudFront when using a custom domain."
  type        = string
  default     = null
}
