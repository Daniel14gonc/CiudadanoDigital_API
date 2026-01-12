# Terraform config
terraform {
  backend "s3" {
    bucket         = var.s3_terraform_state_bucket
    key            = "prod/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.dynamo_db_terraform_lock_table
    encrypt        = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.2"
}