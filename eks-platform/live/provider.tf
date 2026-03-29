terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
  backend "s3" {
    bucket = "ullagalliu-artifacts"
    key    = "eks/dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.common_vars["aws_region"]
}

provider "kubernetes" {
  host                   = module.eks_module.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_module.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"

    command = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks_module.cluster_id
    ]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks_module.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_module.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"

      command = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.eks_module.cluster_id
      ]
    }
  }
}