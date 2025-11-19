module "harmnoix_stack" {
  source = "../../"
  name   = var.name

  environment                = var.environment
  budget_notification_emails = var.budget_notification_emails
}
