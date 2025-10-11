locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "network" {
  source              = "./modules/network"
  project_name        = var.project_name
  environment         = var.environment
  cidr_block          = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  tags                = local.tags
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  target_group_port  = 3000
  health_check_path  = "/health"
  tags               = local.tags
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
  tags         = local.tags
}

module "rds" {
  source                     = "./modules/rds"
  project_name               = var.project_name
  environment                = var.environment
  subnet_ids                 = module.network.private_subnet_ids
  vpc_id                     = module.network.vpc_id
  allowed_cidr_blocks        = []
  db_username                = var.db_username
  db_name                    = var.db_name
  engine_version             = var.db_engine_version
  tags                       = local.tags
}

module "ecs" {
  source                    = "./modules/ecs_service"
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  aws_region                = var.aws_region
  subnet_ids                = module.network.private_subnet_ids
  cluster_name              = "${var.project_name}-${var.environment}"
  desired_count             = 2
  container_port            = 3000
  cpu                       = 512
  memory                    = 1024
  assign_public_ip          = false
  alb_target_group_arn      = module.alb.target_group_arn
  alb_security_group_id     = module.alb.security_group_id
  db_secret_arn             = module.rds.secret_arn
  db_host                   = module.rds.endpoint
  db_name                   = var.db_name
  db_user                   = var.db_username
  ecr_repository_url        = module.ecr.repository_url
  tags                      = local.tags
}

module "s3_cf" {
  source           = "./modules/s3_cf"
  project_name     = var.project_name
  environment      = var.environment
  web_domain_name  = var.web_domain_name
  acm_certificate_arn = var.acm_certificate_arn
  tags             = local.tags
}

module "bootstrap" {
  count              = var.enable_bootstrap ? 1 : 0
  source             = "./modules/bootstrap"
  project_name       = var.project_name
  environment        = var.environment
  github_repository  = var.github_repository
  tags               = local.tags
}

resource "aws_security_group_rule" "db_allow_ecs" {
  description              = "Allow ECS tasks to reach PostgreSQL"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  security_group_id        = module.rds.security_group_id
  source_security_group_id = module.ecs.task_security_group_id
}
