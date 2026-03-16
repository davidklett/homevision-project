variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "homevision"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}

variable "sqs_visibility_timeout" {
  description = "SQS visibility timeout in seconds (should be >= 6x lambda_timeout)"
  type        = number
  default     = 360
}

variable "dlq_max_receive_count" {
  description = "Max receives before message is sent to DLQ"
  type        = number
  default     = 3
}
