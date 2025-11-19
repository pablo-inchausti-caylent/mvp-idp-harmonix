output "budget_ids" {
  description = "IDs of the created budgets"
  value       = { for k, v in aws_budgets_budget.cost_budget : k => v.id }
}

output "budget_arns" {
  description = "ARNs of the created budgets"
  value       = { for k, v in aws_budgets_budget.cost_budget : k => v.arn }
}
