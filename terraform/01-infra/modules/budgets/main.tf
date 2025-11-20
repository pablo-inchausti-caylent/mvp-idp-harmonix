#--------------------------------------------------------------
# AWS Budgets with Email Notifications
#--------------------------------------------------------------

resource "aws_budgets_budget" "cost_budget" {
  for_each = var.budget_limits

  name              = "${var.name}-${var.environment}-budget-${each.key}"
  budget_type       = "COST"
  limit_amount      = each.value
  limit_unit        = "USD"
  time_period_start = "2025-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.notification_emails
  }

  tags = var.tags
}

#--------------------------------------------------------------
# AWS Resource Group - Group all resources
#--------------------------------------------------------------
resource "aws_resourcegroups_group" "harmonix_resources" {
  name        = "${var.name}-resources"
  description = "Resource group for all ${var.name} resources"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Name"
          Values = [var.name]
        }
      ]
    })
  }

  tags = var.tags
}
