locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "random_password" "master" {
  length           = 20
  special          = true
  override_characters = "!#$%&*()-_=+[]{}"
}

resource "aws_db_subnet_group" "this" {
  name       = "${locals.name_prefix}-db-sn"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${locals.name_prefix}-db-sn"
    }
  )
}

resource "aws_security_group" "db" {
  name        = "${locals.name_prefix}-db-sg"
  description = "Allow PostgreSQL ingress"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${locals.name_prefix}-db-sg"
    }
  )
}

resource "aws_security_group_rule" "cidr_ingress" {
  for_each          = toset(var.allowed_cidr_blocks)
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.db.id
}

resource "aws_secretsmanager_secret" "db" {
  name = "${locals.name_prefix}/database"

  tags = merge(
    var.tags,
    {
      Name = "${locals.name_prefix}-db-secret"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier              = "${locals.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  username                = var.db_username
  password                = random_password.master.result
  db_name                 = var.db_name
  multi_az                = var.multi_az
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  deletion_protection     = false
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = true

  tags = merge(
    var.tags,
    {
      Name = "${locals.name_prefix}-postgres"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    engine   = "postgres"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })

  depends_on = [aws_db_instance.this]
}
