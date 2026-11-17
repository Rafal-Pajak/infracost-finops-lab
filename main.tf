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

resource "aws_instance" "app_server" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "m5.large"

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
  }

  tags = {
    Environment = "prod"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "eipalloc-12345678"
  subnet_id     = "subnet-12345678"
}
