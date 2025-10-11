output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS instance."
  value       = module.rds.endpoint
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the database credentials."
  value       = module.rds.secret_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository that stores the application image."
  value       = module.ecr.repository_url
}

output "static_site_domain" {
  description = "Domain name of the CloudFront distribution hosting the static site."
  value       = module.s3_cf.distribution_domain_name
}

output "static_site_distribution_id" {
  description = "CloudFront distribution ID backing the static site."
  value       = module.s3_cf.distribution_id
}

output "static_site_bucket" {
  description = "Name of the S3 bucket that stores the static site."
  value       = module.s3_cf.bucket_name
}

output "bootstrap_role_arns" {
  description = "ARNs of IAM roles created for GitHub OIDC (if enabled)."
  value       = var.enable_bootstrap ? module.bootstrap[0].role_arns : {}
}
