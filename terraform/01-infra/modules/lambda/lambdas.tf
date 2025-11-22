#--------------------------------------------------------------
# Lambda Function with CloudWatch Logs
#--------------------------------------------------------------
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}-ec2-scheduler"
  description   = "EC2 Scheduler Lambda Function"
  handler       = "lambda-EC2-monitor.lambda_handler"
  runtime       = "python3.12"
  timeout       = 20

  source_path = "${path.module}/src/lambda-EC2-monitor.py"

  attach_policy_json = true
  policy_json        = file("${path.module}/src/lambda-EC2-monitor-policy.json")

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 7

  # EventBridge Schedules - Only for EC2
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    EC2StopSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.ec2_stop_schedule.arn
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# EventBridge Rules - Schedule Lambda Execution
#--------------------------------------------------------------

# Stop EC2 instances at 3 AM GMT-3 (6 AM UTC)
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

# NOTE: RDS scheduling has been moved to harmonix-platform-scheduler Lambda

#--------------------------------------------------------------
# Harmonix Platform Scheduler Lambda
#--------------------------------------------------------------
module "harmonix_platform_scheduler" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}-harmonix-platform-scheduler"
  description   = "Start/Stop Harmonix Platform Services (RDS + ECS Backstage)"
  handler       = "lambda-harmonix-platform-scheduler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  source_path = "${path.module}/src/lambda-harmonix-platform-scheduler.py"

  attach_policy_json = true
  policy_json        = file("${path.module}/src/lambda-harmonix-platform-scheduler-policy.json")

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 7

  # Environment Variables
  environment_variables = {
    PLATFORM_PREFIX = "opa-platform"
  }

  # EventBridge Schedules
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    HarmonixStopSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.harmonix_stop_schedule.arn
    }
    HarmonixStartSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.harmonix_start_schedule.arn
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# EventBridge Rules - Harmonix Platform Schedule
#--------------------------------------------------------------

# Stop Harmonix Platform at 3:15 AM GMT-3 (6:15 AM UTC)
resource "aws_cloudwatch_event_rule" "harmonix_stop_schedule" {
  name                = "${var.name}-harmonix-stop-schedule"
  description         = "Stop Harmonix Platform (RDS + ECS) daily at 3:15 AM GMT-3"
  schedule_expression = "cron(15 6 * * ? *)" # 6:15 AM UTC = 3:15 AM GMT-3

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "harmonix_stop_target" {
  rule      = aws_cloudwatch_event_rule.harmonix_stop_schedule.name
  target_id = "HarmonixStopTarget"
  arn       = module.harmonix_platform_scheduler.lambda_function_arn
  input     = jsonencode({ action = "stop" })
}

# Start Harmonix Platform at 9:00 AM GMT-3 (12:00 PM UTC)
resource "aws_cloudwatch_event_rule" "harmonix_start_schedule" {
  name                = "${var.name}-harmonix-start-schedule"
  description         = "Start Harmonix Platform (RDS + ECS) daily at 9:00 AM GMT-3"
  schedule_expression = "cron(0 12 * * ? *)" # 12:00 PM UTC = 9:00 AM GMT-3

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "harmonix_start_target" {
  rule      = aws_cloudwatch_event_rule.harmonix_start_schedule.name
  target_id = "HarmonixStartTarget"
  arn       = module.harmonix_platform_scheduler.lambda_function_arn
  input     = jsonencode({ action = "start" })
}