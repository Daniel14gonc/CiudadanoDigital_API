# Security groups

resource "aws_security_group" "comp_digital_sg" {
  name        = "compdi-sg"
  description = "SG for comp-digital instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "compdi-sg"
  }
}

resource "aws_security_group" "comp_digital_db_sg" {
  name        = "compdi-db-sg"
  description = "SG for comp-digital-db instance"
  vpc_id      = "vpc-062783db5dfab73ab"

  ingress {
    description = "Postgres my IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.http_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "compdi-sg"
  }
}