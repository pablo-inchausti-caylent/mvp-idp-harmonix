# IAM OIDC Role Module

This module creates an IAM role for OIDC integration with GitLab, allowing GitLab CI/CD pipelines to assume AWS roles using Web Identity.

## Features

- Creates an IAM role with OIDC trust relationship
- Attaches AdministratorAccess policy (can be customized)
- Parameterized project name, branch, and OIDC provider
- AWS account ID automatically retrieved from current context

## Usage

### Basic Example

```hcl
module "oidc_iam_role" {
  source = "./modules/iam"

  name              = "harmonix_mvp"
  project_name      = "aws-environment-providers/gen-ia-demo"
  oidc_provider_url = "git.harmonix.glaciar.org"
  ref_type          = "branch"
  ref_name          = "main"

  tags = {
    Environment = "dev"
    Project     = "harmonix"
  }
}
```

### Multiple Projects Example

```hcl
# Production role for main branch
module "oidc_role_prod" {
  source = "./modules/iam"

  name              = "harmonix_prod"
  project_name      = "aws-environment-providers/production-app"
  oidc_provider_url = "git.harmonix.glaciar.org"
  ref_type          = "branch"
  ref_name          = "main"

  tags = {
    Environment = "production"
    Project     = "harmonix"
  }
}

# Development role for develop branch
module "oidc_role_dev" {
  source = "./modules/iam"

  name              = "harmonix_dev"
  project_name      = "aws-environment-providers/dev-app"
  oidc_provider_url = "git.harmonix.glaciar.org"
  ref_type          = "branch"
  ref_name          = "develop"

  tags = {
    Environment = "development"
    Project     = "harmonix"
  }
}
```

## Requirements

- An OIDC provider must be created in AWS IAM first
- The OIDC provider URL should match your GitLab instance
- GitLab project must be configured to use OIDC authentication

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for the IAM role | string | n/a | yes |
| project_name | GitLab project path (e.g., 'aws-environment-providers/gen-ia-demo') | string | n/a | yes |
| oidc_provider_url | OIDC provider URL (e.g., 'git.harmonix.glaciar.org') | string | "git.harmonix.glaciar.org" | no |
| ref_type | Git reference type (e.g., 'branch', 'tag') | string | "branch" | no |
| ref_name | Git reference name (e.g., 'main', 'develop') | string | "main" | no |
| tags | A map of tags to assign to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| oidc_role_arn | ARN of the OIDC IAM role |
| oidc_role_name | Name of the OIDC IAM role |
| oidc_role_id | ID of the OIDC IAM role |
| oidc_provider_arn | ARN of the OIDC provider |

## Trust Relationship

The role trust policy allows:
- **Principal**: OIDC provider at `git.harmonix.glaciar.org`
- **Action**: `sts:AssumeRoleWithWebIdentity`
- **Conditions**:
  - Audience must match: `https://git.harmonix.glaciar.org`
  - Subject must match: `project_path:{project_name}:ref_type:{ref_type}:ref:{ref_name}`

## GitLab CI/CD Configuration

To use this role in GitLab CI/CD:

```yaml
deploy:
  stage: deploy
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://git.harmonix.glaciar.org
  before_script:
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role-with-web-identity
      --role-arn ${ROLE_ARN}
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token $GITLAB_OIDC_TOKEN
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))
  script:
    - aws sts get-caller-identity
    - # Your deployment commands here
  variables:
    ROLE_ARN: "arn:aws:iam::${AWS_ACCOUNT_ID}:role/harmonix_mvp_oidc_role"
```

## Security Considerations

⚠️ **Important**: This module currently attaches the `AdministratorAccess` policy. For production use, consider:
- Creating custom IAM policies with minimal required permissions
- Using separate roles for different environments
- Implementing branch protection rules in GitLab
- Auditing role usage through CloudTrail

## Example Output

After applying, you can get the role ARN:

```bash
terraform output oidc_role_arn
# Output: arn:aws:iam::198804754422:role/harmonix_mvp_oidc_role
```
