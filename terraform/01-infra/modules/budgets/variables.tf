variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "budget_limits" {
  type        = map(string)
  description = "Map of budget names to limits in USD"
  default = {
    "warning"  = "5"
    "critical" = "15"
    "maximum"  = "50"
  }
}

variable "notification_emails" {
  type        = list(string)
  description = "List of email addresses to receive budget notifications"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources"
  default     = {}
}
