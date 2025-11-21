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

output "rds_start_rule_arn" {
  description = "The ARN of the RDS start EventBridge rule"
  value       = aws_cloudwatch_event_rule.rds_start_schedule.arn
}

output "rds_stop_rule_arn" {
  description = "The ARN of the RDS stop EventBridge rule"
  value       = aws_cloudwatch_event_rule.rds_stop_schedule.arn
}
