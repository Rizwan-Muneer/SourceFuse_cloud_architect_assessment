variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az" {
  description = "Availability Zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_az" {
  description = "Availability Zone for the private subnet"
  type        = string
  default     = "us-east-1b"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "nginx-cluster"
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "nginx-lb"
}

variable "alb_internal" {
  description = "Whether the ALB should be internal (true/false)"
  type        = bool
  default     = false
}

variable "alb_type" {
  description = "Type of the ALB (application/network)"
  type        = string
  default     = "application"
}

variable "ecs_execution_role_name" {
  description = "Name of the ECS execution role"
  type        = string
  default     = "ecs-execution-role"
}

variable "ecs_task_family" {
  description = "ECS task family name"
  type        = string
  default     = "nginx-nginx"
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task"
  type        = string
  default     = "512"
}

variable "ecs_container_cpu" {
  description = "CPU units for the ECS container"
  type        = string
  default     = "256"
}

variable "ecs_container_memory" {
  description = "Memory for the ECS container"
  type        = string
  default     = "512"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "nginx-service"
}

variable "ecs_desired_count" {
  description = "Desired count of ECS tasks"
  type        = number
  default     = 1
}

variable "alb_listener_rule_priority" {
  description = "Priority of the ALB listener rule"
  type        = number
  default     = 100
}

variable "alb_listener_host_header" {
  description = "Host header for the ALB listener rule"
  type        = string
  default     = "nginx.com"
}

variable "alb_listener_path_pattern" {
  description = "Path pattern for the ALB listener rule"
  type        = string
  default     = "/"
}

variable "alb_target_group_name" {
  description = "Name of the ALB target group"
  type        = string
  default     = "nginx-target-group"
}

variable "alb_target_group_port" {
  description = "Port for the ALB target group"
  type        = number
  default     = 80
}

variable "alb_target_group_protocol" {
  description = "Protocol for the ALB target group"
  type        = string
  default     = "HTTP"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "nginx999999-bucket-name"
}

variable "iam_role_name" {
  description = "Name of the IAM role for S3 access"
  type        = string
  default     = "ecs-s3-access-role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy for S3 access"
  type        = string
  default     = "s3-write-policy"
}

variable "iam_policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Allows write access to S3 bucket"
}

