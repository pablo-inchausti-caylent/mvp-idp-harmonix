module "harmnoix_stack" {
  source = "../../"
  name   = var.name

  environment                = var.environment
  budget_notification_emails = var.budget_notification_emails

  # OIDC Configuration
  gitlab_project_name      = var.gitlab_project_name
  gitlab_oidc_provider_url = var.gitlab_oidc_provider_url
  gitlab_ref_type          = var.gitlab_ref_type
  gitlab_ref_name          = var.gitlab_ref_name
}
