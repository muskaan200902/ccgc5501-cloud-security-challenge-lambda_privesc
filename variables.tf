# =============================================================================
# Lambda Privilege Escalation Lab - Variables
# =============================================================================

variable "profile" {
  description = "AWS CLI profile to use for deployment"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "lab_id" {
  description = "Unique ID for resource naming (e.g., 'abc123')"
  type        = string
  default     = "lambda_privesc"
}

variable "scenario_name" {
  description = "Name of the scenario"
  type        = string
  default     = "lambda-privesc"
}

variable "stack_name" {
  description = "Stack name for tagging"
  type        = string
  default     = "SecurityLab"
}
