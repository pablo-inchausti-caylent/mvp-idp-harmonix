#--------------------------------------------------------------
# Main Stack :: name - tags - env
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "The name of the implementation of the module"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "Accept only letters, numbers, dashes, and underscores"
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the module"
  default     = {}
}

variable "environment" {
  description = "The name of the environment (dev, test, examples, stage)"
  type        = string
  default     = "test"
}

variable "budget_notification_emails" {
  description = "List of email addresses to receive budget notifications"
  type        = list(string)
  default     = []
}
