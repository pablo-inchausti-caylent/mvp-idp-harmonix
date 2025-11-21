#--------------------------------------------------------------
# IAM Role for OIDC Integration
#--------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
}

resource "aws_iam_role" "oidc_role" {
  name               = "${var.name}_oidc_role"
  description        = "IAM role for OIDC integration with GitLab - Project: ${var.project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:aud" = "https://${var.oidc_provider_url}"
          }
          StringLike = {
            "${var.oidc_provider_url}:sub" = "project_path:${var.project_name}:ref_type:${var.ref_type}:ref:${var.ref_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
