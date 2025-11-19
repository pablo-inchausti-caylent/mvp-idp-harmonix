##--------------
# This script sets up the backend for Terraform state management using S3 and DynamoDB.
# This can't be managed by terraform, because the backend configuration is required
# to be set before any resources are created.
##-----------


# Create an S3 Bucket and DynamoDB Table


TERRAFORM_ST_REGION=us-east-1
TERRAFORM_S3_BUCKET=harmonix-mvp-3377-tf-state



PROJECT_S3_KEY_VALUES="{Key=caylent:owner,Value='pablo.inchausti@caylent.com'},{Key=caylent:project,Value='harmonix-mvp'},{Key=caylent:workload,Value='harmonix-mvp'},{Key=map-migrated,Value='mig-Harmonix-2025'},{Key=caylent:deployment-mode,Value='aws-cli-script'}"
PROJECT_S3_TAGS="TagSet=[$PROJECT_S3_KEY_VALUES]"


aws sts get-caller-identity > /tmp/assume-role.log;  cat /tmp/assume-role.log

echo "Terraform region      : $TERRAFORM_ST_REGION"
echo "Terraform S3 bucket   : $TERRAFORM_S3_BUCKET"

read -p "Do you want to continue? (y/n) " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo "Cancelled by user."
  exit 1
fi


## S3 Bucket for Terraform state
if aws s3api head-bucket --bucket $TERRAFORM_S3_BUCKET 2>/dev/null; then
  echo "Bucket $TERRAFORM_S3_BUCKET already exists, skipping creation."
else
  aws s3api create-bucket \
    --bucket $TERRAFORM_S3_BUCKET --region $TERRAFORM_ST_REGION || exit 1
fi

## S3 Bucket for Terraform state - Tagging
aws s3api put-bucket-tagging \
  --bucket "$TERRAFORM_S3_BUCKET" \
  --tagging "$PROJECT_S3_TAGS"  || exit 1

## S3 Bucket for Terraform state - Enable Versioning
aws s3api put-bucket-versioning \
  --bucket $TERRAFORM_S3_BUCKET \
  --versioning-configuration Status=Enabled || exit 1



exit 0
