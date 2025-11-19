#--------------------------------------------------------------
# Environments
#     - Dev      - Sandbox AWS Account Glaciar   <-- this tfvar
#     - Test     - Caylent AWS Dev/Test       
#
#--------------------------------------------------------------


name = "harmonix-mvp"

environment = "dev"

aws_region = "us-east-1"

budget_notification_emails = [
#  "pablo.inchausti+alert+3377@caylent.com",
   "pablo.inchausti+alert+3377@glaciar.io",
]

default_tags = {
  "caylent:owner"      = "pablo.inchausti@caylent.com"
  "caylent:project"    = "harmonix-mvp"
  "caylent:workload"   = "harmonix-mvp"
  "map-migrated"       = "mig-Harmonix-2025"
  "environment"        = "dev"
  "deployment-mode"    = "terraform-stack"      # terraform-stack | aws-cli-script | aws-console-manual
  "resources-group-id" = "gid-v20251119-v1.0"   # gid-vYYYYMMDD-semver-(alfa, beta, rc, stable, final)
}

