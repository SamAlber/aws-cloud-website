terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specify the source for the AWS provider
      version = "~> 5.76.0"     # Use a stable version of the AWS provider
    }
    cloudflare = {
      source  = "cloudflare/cloudflare" # Cloudflare provider source
      version = "5.0.0-alpha1"          # Use the version you specified
    }
  }
}

provider "aws" {
  region = var.aws_region # AWS provider configuration
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token # Cloudflare provider configuration
}
