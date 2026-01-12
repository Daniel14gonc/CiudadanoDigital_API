# Variables

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "s3_terraform_state_bucket" {
  type        = string
  description = "S3 bucket for Terraform state"
}

variable "dynamo_db_terraform_lock_table" {
  type        = string
  description = "DynamoDB table for Terraform state locking"
}

variable "instance_type" {
  type    = string
  default = "m7i-flex.large"
}

variable "bucket_name" {
  type    = string
  default = "comp-digital-bucket"
}

variable "database_username" {
  type        = string
  sensitive   = true
}

variable "database_password" {
  type        = string
  sensitive   = true
}

locals {
  subnets_availability_zone_a = "${var.aws_region}a"
  subnets_availability_zone_b = "${var.aws_region}b"
}