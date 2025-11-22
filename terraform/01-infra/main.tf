resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "null_resource" "this" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "echo '${random_password.this.result}' > /tmp/${var.name}_password.txt"
  }
  provisioner "local-exec" {
    command = "echo -e '${jsonencode(local.tags)}' > /tmp/${var.name}_tags.txt"
  }
}


#--------------------------------------------------------------
# LAMBDA
#--------------------------------------------------------------
module "harmonix_lambda" {
  source = "./modules/lambda"
  name   = var.name
  tags   = local.tags
}

#--------------------------------------------------------------
# AWS BUDGETS :: COST ALARMS
#--------------------------------------------------------------
module "budgets" {
  source = "./modules/budgets"

  name                = var.name
  environment         = var.environment
  notification_emails = var.budget_notification_emails

  budget_limits = {
    "warning"  = "5"
    "critical" = "15"
    "maximum"  = "50"
  }

  tags = local.tags
}

#--------------------------------------------------------------
# IAM :: OIDC ROLE
#--------------------------------------------------------------
module "oidc_iam_role" {
  source = "./modules/iam"

  name              = replace(var.name, "-", "_")
  project_name      = var.gitlab_project_name
  oidc_provider_url = var.gitlab_oidc_provider_url
  ref_type          = var.gitlab_ref_type
  ref_name          = var.gitlab_ref_name

  tags = local.tags
}


output "generated_password" {
  description = "The generated random password."
  value       = random_password.this.result
  sensitive   = true
}

output "lambda_function_name" {
  description = "Name of the EC2 Monitor Lambda function"
  value       = module.harmonix_lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the EC2 Monitor Lambda function"
  value       = module.harmonix_lambda.lambda_function_arn
}

output "lambda_log_group" {
  description = "CloudWatch Log Group for Lambda function"
  value       = module.harmonix_lambda.lambda_cloudwatch_log_group
}

output "budget_ids" {
  description = "IDs of the created budgets"
  value       = module.budgets.budget_ids
}

output "budget_arns" {
  description = "ARNs of the created budgets"
  value       = module.budgets.budget_arns
}

output "resource_group_arn" {
  description = "ARN of the Harmonix MVP resource group"
  value       = module.budgets.resource_group_arn
}

output "resource_group_name" {
  description = "Name of the Harmonix MVP resource group"
  value       = module.budgets.resource_group_name
}

output "ec2_stop_eventbridge_rule_arn" {
  description = "ARN of the EC2 stop EventBridge schedule rule (3 AM GMT-3)"
  value       = module.harmonix_lambda.ec2_stop_rule_arn
}

# Harmonix Platform Scheduler Outputs
output "harmonix_platform_scheduler_arn" {
  description = "ARN of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmonix_lambda.harmonix_platform_scheduler_arn
}

output "harmonix_platform_scheduler_name" {
  description = "Name of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmonix_lambda.harmonix_platform_scheduler_name
}

output "harmonix_stop_eventbridge_rule_arn" {
  description = "ARN of the Harmonix platform stop EventBridge schedule rule (3:15 AM GMT-3)"
  value       = module.harmonix_lambda.harmonix_stop_rule_arn
}

output "harmonix_start_eventbridge_rule_arn" {
  description = "ARN of the Harmonix platform start EventBridge schedule rule (9:00 AM GMT-3)"
  value       = module.harmonix_lambda.harmonix_start_rule_arn
}

output "oidc_role_arn" {
  description = "ARN of the OIDC IAM role for GitLab integration"
  value       = module.oidc_iam_role.oidc_role_arn
}

output "oidc_role_name" {
  description = "Name of the OIDC IAM role"
  value       = module.oidc_iam_role.oidc_role_name
}


