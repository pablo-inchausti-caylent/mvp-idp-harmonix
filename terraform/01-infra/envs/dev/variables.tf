variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "The name of the implementation of the module"
  default     = "harmonix-mvp"
}

variable "environment" {
  description = "The name of the environment (dev, test, examples, stage)"
  type        = string
  default     = "dev"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags applied by provider"
  default     = {}
}

variable "budget_notification_emails" {
  description = "List of email addresses to receive budget notifications"
  type        = list(string)
  default     = []
}

