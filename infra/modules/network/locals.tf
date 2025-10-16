locals {
  name_prefix = "${var.environment}-${var.service_name}"
  azs        = ["${var.aws_region}a", "${var.aws_region}b"]
}
