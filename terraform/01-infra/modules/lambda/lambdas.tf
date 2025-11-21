#--------------------------------------------------------------
# Lambda Function with CloudWatch Logs
#--------------------------------------------------------------
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}-ec2-rds-scheduler"
  description   = "EC2 and RDS Scheduler Lambda Function"
  handler       = "lambda-EC2-monitor.lambda_handler"
  runtime       = "python3.12"
  timeout       = 20

  source_path = "${path.module}/src/lambda-EC2-monitor.py"

  attach_policy_json = true
  policy_json        = file("${path.module}/src/lambda-EC2-monitor-policy.json")

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 7

  # EventBridge Schedules - Multiple triggers for EC2 and RDS
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    EC2StopSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.ec2_stop_schedule.arn
    }
    RDSStartSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.rds_start_schedule.arn
    }
    RDSStopSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.rds_stop_schedule.arn
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# EventBridge Rules - Schedule Lambda Execution
#--------------------------------------------------------------

# 1. Stop EC2 instances at 3 AM GMT-3 (6 AM UTC)
resource "aws_cloudwatch_event_rule" "ec2_stop_schedule" {
  name                = "${var.name}-ec2-stop-schedule"
  description         = "Stop EC2 instances daily at 3 AM GMT-3"
  schedule_expression = "cron(0 6 * * ? *)" # 6 AM UTC = 3 AM GMT-3

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "ec2_stop_target" {
  rule      = aws_cloudwatch_event_rule.ec2_stop_schedule.name
  target_id = "EC2StopTarget"
  arn       = module.lambda_function.lambda_function_arn
  input     = jsonencode({ action = "stop" })
}

# 2. Start RDS instances at 9 AM GMT-3 (12 PM UTC)
resource "aws_cloudwatch_event_rule" "rds_start_schedule" {
  name                = "${var.name}-rds-start-schedule"
  description         = "Start RDS instances daily at 9 AM GMT-3"
  schedule_expression = "cron(0 12 * * ? *)" # 12 PM UTC = 9 AM GMT-3

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "rds_start_target" {
  rule      = aws_cloudwatch_event_rule.rds_start_schedule.name
  target_id = "RDSStartTarget"
  arn       = module.lambda_function.lambda_function_arn
  input     = jsonencode({ action = "start" })
}

# 3. Stop RDS instances at 3:15 AM GMT-3 (6:15 AM UTC)
resource "aws_cloudwatch_event_rule" "rds_stop_schedule" {
  name                = "${var.name}-rds-stop-schedule"
  description         = "Stop RDS instances daily at 3:15 AM GMT-3"
  schedule_expression = "cron(15 6 * * ? *)" # 6 AM UTC = 3 AM GMT-3

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "rds_stop_target" {
  rule      = aws_cloudwatch_event_rule.rds_stop_schedule.name
  target_id = "RDSStopTarget"
  arn       = module.lambda_function.lambda_function_arn
  input     = jsonencode({ action = "stop" })
}