# Resources
terraform { 
  cloud { 
    
    organization = "comp-digital" 

    workspaces { 
      name = "comp-digital" 
    } 
  } 
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  # También filtrar por arquitectura por si acaso
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "comp_digital" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type # setear por defecto a "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.comp_digital_sg.id]
  key_name               = var.existing_key_name

  root_block_device {
    volume_size = 30 # <=30GB ayuda a no salirse del free tier
    volume_type = "gp3"
  }

  tags = {
    Name = "compdi-instance"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_db_instance" "comp_digital_db" {
  identifier             = "comp-digital-db"
  instance_class         = "db.t4g.micro"
  engine                 = "postgres"
  engine_version         = "17.6"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = "default-vpc-062783db5dfab73ab"
  vpc_security_group_ids = [aws_security_group.comp_digital_db_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  allocated_storage      = 400
}