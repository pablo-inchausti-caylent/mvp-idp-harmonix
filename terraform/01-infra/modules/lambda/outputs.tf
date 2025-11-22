output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.lambda_function.lambda_function_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda_function.lambda_function_name
}

output "lambda_cloudwatch_log_group" {
  description = "The CloudWatch Log Group for the Lambda function"
  value       = module.lambda_function.lambda_cloudwatch_log_group_name
}

output "ec2_stop_rule_arn" {
  description = "The ARN of the EC2 stop EventBridge rule"
  value       = aws_cloudwatch_event_rule.ec2_stop_schedule.arn
}

# Harmonix Platform Scheduler Outputs
output "harmonix_platform_scheduler_arn" {
  description = "The ARN of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmonix_platform_scheduler.lambda_function_arn
}

output "harmonix_platform_scheduler_name" {
  description = "The name of the Harmonix Platform Scheduler Lambda function"
  value       = module.harmonix_platform_scheduler.lambda_function_name
}

output "harmonix_stop_rule_arn" {
  description = "The ARN of the Harmonix platform stop EventBridge rule"
  value       = aws_cloudwatch_event_rule.harmonix_stop_schedule.arn
}

output "harmonix_start_rule_arn" {
  description = "The ARN of the Harmonix platform start EventBridge rule"
  value       = aws_cloudwatch_event_rule.harmonix_start_schedule.arn
}
