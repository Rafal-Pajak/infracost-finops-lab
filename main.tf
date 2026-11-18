terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "eu-central-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

locals {
  common_tags = {
    Environment = "prod"
    Owner       = "platform-team"
    CostCenter  = "CC-4100"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "app-server-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "app-server-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "app_server" {
  ami                  = "ami-0123456789abcdef0"
  instance_type        = "t3.medium"
  ebs_optimized        = true
  monitoring           = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "app-server-01"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "eipalloc-12345678"
  subnet_id     = "subnet-12345678"

  tags = merge(local.common_tags, {
    Name = "main-nat-gw"
  })
}
