output "budget_ids" {
  description = "IDs of the created budgets"
  value       = { for k, v in aws_budgets_budget.cost_budget : k => v.id }
}

output "budget_arns" {
  description = "ARNs of the created budgets"
  value       = { for k, v in aws_budgets_budget.cost_budget : k => v.arn }
}

output "resource_group_arn" {
  description = "ARN of the Harmonix MVP resource group"
  value       = aws_resourcegroups_group.harmonix_resources.arn
}

output "resource_group_name" {
  description = "Name of the Harmonix MVP resource group"
  value       = aws_resourcegroups_group.harmonix_resources.name
}
