variable "name" {
  type        = string
  description = "Name prefix for the IAM role"
}

variable "project_name" {
  type        = string
  description = "GitLab project path (e.g., 'aws-environment-providers/gen-ia-demo')"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL (e.g., 'git.harmonix.glaciar.org')"
  default     = "git.harmonix.glaciar.org"
}

variable "ref_type" {
  type        = string
  description = "Git reference type (e.g., 'branch', 'tag')"
  default     = "branch"
}

variable "ref_name" {
  type        = string
  description = "Git reference name (e.g., 'main', 'develop')"
  default     = "main"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources"
  default     = {}
}
