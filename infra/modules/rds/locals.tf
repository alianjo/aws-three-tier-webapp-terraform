locals {
  name_prefix = "${var.environment}-${var.service_name}"
  db_name     = replace("${local.name_prefix}-db", "-", "_")
}
