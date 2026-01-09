terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
  backend "s3" {
    bucket = "ullagalliu-artifacts"
    key    = "eks-infra-platform/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.common_vars["aws_region"]
}
