# Variables

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "m7i-flex.large"
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
  default = "181.209.150.71/32"
}

variable "http_EC2" {
  type    = string
  default = "3.136.3.106/32"
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

variable "elastic_ip_id" {
  description = "elastic IP for EC2"
  type = string
  default = "eipalloc-0fe90292dc06e9ae7"
}

variable "subnets_availability_zone_a" {
  description = "availability zone for subnets"
  type = string
  default = "us-east-2a"
}

variable "subnets_availability_zone_b" {
  description = "availability zone for subnets"
  type = string
  default = "us-east-2b"
}