locals {
  # Base naming
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Terraform   = "true"
    }
  )
  
  # Network settings
  az_count = length(var.availability_zones)
  max_azs  = min(local.az_count, 3)  # Use up to 3 AZs
}
