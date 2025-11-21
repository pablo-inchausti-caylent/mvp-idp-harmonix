output "oidc_role_arn" {
  description = "ARN of the OIDC IAM role"
  value       = aws_iam_role.oidc_role.arn
}

output "oidc_role_name" {
  description = "Name of the OIDC IAM role"
  value       = aws_iam_role.oidc_role.name
}

output "oidc_role_id" {
  description = "ID of the OIDC IAM role"
  value       = aws_iam_role.oidc_role.id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = local.oidc_provider_arn
}
