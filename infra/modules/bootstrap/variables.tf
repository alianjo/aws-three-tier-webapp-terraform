variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., dev, staging, prod)"
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}
