variable "project_name" {
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "alb_target_group_arn" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "app"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "The ARN of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "The ARN of the task definition to run"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task to run"
  type        = number
  default     = 2
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "task_cpu" {
  description = "The number of CPU units to reserve for the task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to reserve for the task"
  type        = string
  default     = "512"
}

variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Port on the host to map to the container port"
  type        = number
  default     = 0  # 0 means random port
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "assign_public_ip" {
  type    = bool
  default = false
}
