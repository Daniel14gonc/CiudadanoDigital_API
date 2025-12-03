# Variables

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "existing_key_name" {
  type    = string
  default = "ciudadano"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "http_cidr" {
  type    = string
  default = "190.56.32.67/32"
}

variable "subnet_id" {
  type    = string
  default = "subnet-05155c9661daeda26"
}

variable "bucket_name" {
  type    = string
  default = "comp-digital-bucket"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "postgres"
}