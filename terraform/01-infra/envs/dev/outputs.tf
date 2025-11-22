#------------------------------------------------------------
# ONIX Stack for Caylent Dev/Test Environment
#------------------------------------------------------------
output "account_id" {
  value       = data.aws_caller_identity.me.account_id
  description = "Account ID of the AWS caller"
}

output "caller_arn" {
  value       = data.aws_caller_identity.me.arn
  description = "ARN of the AWS caller"
}

output "region" {
  value       = data.aws_region.current.id
  description = "Region of the AWS caller"
}

#------------------------------------------------------------
# Lambda Function Outputs
#------------------------------------------------------------
output "lambda_function_name" {
  description = "Name of the EC2 Monitor Lambda function"
  value       = module.harmnoix_stack.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the EC2 Monitor Lambda function"
  value       = module.harmnoix_stack.lambda_function_arn
}

output "lambda_log_group" {
  description = "CloudWatch Log Group for Lambda function"
  value       = module.harmnoix_stack.lambda_log_group
}

output "ec2_stop_eventbridge_rule_arn" {
  description = "ARN of the EC2 stop EventBridge schedule rule (3 AM GMT-3)"
  value       = module.harmnoix_stack.ec2_stop_eventbridge_rule_arn
}

#------------------------------------------------------------
# Harmonix Platform Scheduler Outputs
#------------------------------------------------------------
output "harmonix_platform_scheduler_arn" {
  description = "ARN of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmnoix_stack.harmonix_platform_scheduler_arn
}

output "harmonix_platform_scheduler_name" {
  description = "Name of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmnoix_stack.harmonix_platform_scheduler_name
}

output "harmonix_stop_eventbridge_rule_arn" {
  description = "ARN of the Harmonix platform stop EventBridge schedule rule (3:15 AM GMT-3)"
  value       = module.harmnoix_stack.harmonix_stop_eventbridge_rule_arn
}

output "harmonix_start_eventbridge_rule_arn" {
  description = "ARN of the Harmonix platform start EventBridge schedule rule (9:00 AM GMT-3)"
  value       = module.harmnoix_stack.harmonix_start_eventbridge_rule_arn
}

#------------------------------------------------------------
# Budget Outputs
#------------------------------------------------------------
output "budget_ids" {
  description = "IDs of the created budgets"
  value       = module.harmnoix_stack.budget_ids
}

output "budget_arns" {
  description = "ARNs of the created budgets"
  value       = module.harmnoix_stack.budget_arns
}

output "resource_group_arn" {
  description = "ARN of the Harmonix MVP resource group"
  value       = module.harmnoix_stack.resource_group_arn
}

output "resource_group_name" {
  description = "Name of the Harmonix MVP resource group"
  value       = module.harmnoix_stack.resource_group_name
}

#------------------------------------------------------------
# Generated Password Output
#------------------------------------------------------------
output "generated_password" {
  description = "The generated random password"
  value       = module.harmnoix_stack.generated_password
  sensitive   = true
}

#------------------------------------------------------------
# OIDC IAM Role Outputs
#------------------------------------------------------------
output "oidc_role_arn" {
  description = "ARN of the OIDC IAM role for GitLab integration"
  value       = module.harmnoix_stack.oidc_role_arn
}

output "oidc_role_name" {
  description = "Name of the OIDC IAM role"
  value       = module.harmnoix_stack.oidc_role_name
}
