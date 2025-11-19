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

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge schedule rule"
  value       = module.harmnoix_stack.eventbridge_rule_arn
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

#------------------------------------------------------------
# Generated Password Output
#------------------------------------------------------------
output "generated_password" {
  description = "The generated random password"
  value       = module.harmnoix_stack.generated_password
  sensitive   = true
}
