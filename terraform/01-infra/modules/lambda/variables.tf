variable "name" {
  type        = string
  description = "Name prefix for all resources"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources"
  default     = {}
}
