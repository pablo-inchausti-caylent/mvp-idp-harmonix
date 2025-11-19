locals {
  default_tags = {
    Terraform = "true"
    Name      = var.name
  }
  tags = merge(local.default_tags, var.tags)
}
