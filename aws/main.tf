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

resource "aws_db_parameter_group" "postgres_audit" {
  name   = "prod-core-banking-pg15"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Environment = "prod"
    Owner       = "core-banking"
    CostCenter  = "CC-901"
  }
}

resource "aws_db_instance" "compliant_prod_db" {
  identifier                          = "prod-core-banking-db"
  engine                              = "postgres"
  engine_version                      = "15.4"
  instance_class                      = "db.t4g.micro"
  allocated_storage                   = 20
  multi_az                            = true
  storage_encrypted                   = true
  kms_key_id                          = "arn:aws:kms:eu-central-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  backup_retention_period             = 7
  deletion_protection                 = true
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = "arn:aws:kms:eu-central-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  monitoring_interval                 = 60
  monitoring_role_arn                 = "arn:aws:iam::123456789012:role/rds-monitoring-role"
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  parameter_group_name                = aws_db_parameter_group.postgres_audit.name
  copy_tags_to_snapshot               = true
  skip_final_snapshot                 = true

  tags = {
    Environment = "prod"
    Owner       = "core-banking"
    CostCenter  = "CC-901"
  }
}
