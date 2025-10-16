locals {
  repo_ref_patterns = ["repo:${var.github_org}/${var.github_repo}:*"]
  name_prefix      = "${var.environment}-${var.service_name}"
}
