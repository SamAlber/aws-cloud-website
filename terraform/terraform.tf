terraform { # Best Practice! 
    required_version = "1.9.8"
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.76.0"
      }
      cloudflare = {
        source = "cloudflare/cloudflare"
        version = "5.0.0-alpha1"
      }
      random = {
        source = "hashicorp/randon"
        version = "3.6.3"
      }
    }
}

