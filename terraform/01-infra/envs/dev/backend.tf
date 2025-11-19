terraform {
  backend "s3" {
    bucket = "harmonix-mvp-3377-tf-state"
    key    = "harmonix-mvp/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
