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

#--------------------------------------------------------------
# OIDC Configuration
#--------------------------------------------------------------
variable "gitlab_project_name" {
  description = "GitLab project path for OIDC integration (e.g., 'aws-environment-providers/gen-ia-demo')"
  type        = string
  default     = "aws-environment-providers/gen-ia-demo"
}

variable "gitlab_oidc_provider_url" {
  description = "GitLab OIDC provider URL"
  type        = string
  default     = "git.harmonix.glaciar.org"
}

variable "gitlab_ref_type" {
  description = "Git reference type for OIDC (branch, tag)"
  type        = string
  default     = "branch"
}

variable "gitlab_ref_name" {
  description = "Git reference name for OIDC (e.g., 'main', 'develop')"
  type        = string
  default     = "main"
}

