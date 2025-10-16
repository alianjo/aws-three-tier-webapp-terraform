locals {
  name_prefix = "${var.environment}-${var.service_name}"
  container_name = var.container_name != "" ? var.container_name : var.service_name
}
