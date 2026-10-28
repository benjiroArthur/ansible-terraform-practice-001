terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    # Used to look up this machine's public IP for the SSH ingress rule.
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}