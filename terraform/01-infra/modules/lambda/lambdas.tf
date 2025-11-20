#--------------------------------------------------------------
# Lambda Function with CloudWatch Logs
#--------------------------------------------------------------
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}-ec2-monitor"
  description   = "EC2 Monitor and Shutdown Lambda Function"
  handler       = "lambda-EC2-monitor.lambda_handler"
  runtime       = "python3.12"
  timeout       = 20

  source_path = "${path.module}/src/lambda-EC2-monitor.py"

  attach_policy_json = true
  policy_json        = file("${path.module}/src/lambda-EC2-monitor-policy.json")

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 7

  # EventBridge Schedule - Run every day at 4 AM GMT-3 (7 AM UTC)
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    EventBridgeSchedule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_schedule.arn
    }
  }

  tags = var.tags
}

#--------------------------------------------------------------
# EventBridge Rule - Schedule Lambda Execution
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.name}-ec2-monitor-schedule"
  description         = "Trigger Lambda to shutdown EC2 instances daily"
  schedule_expression = "cron(0 7 * * ? *)" # 7 AM UTC = 4 AM GMT-3 (ART - Argentina Time)

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "TriggerLambda"
  arn       = module.lambda_function.lambda_function_arn
}