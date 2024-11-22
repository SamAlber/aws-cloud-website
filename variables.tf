variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "verified_sender_email" {
  description = "Verified email address for SES"
  type        = string
  default     = "sam.albershtein@gmail.com"  # Replace with your SES verified email
}

variable "cloudfront_private_key" {
  description = "CloudFront private key in PEM format"
  type        = string
  sensitive   = true
}

variable "cloudfront_key_pair_id" {
  description = "CloudFront key pair ID"
  type        = string
}

# These variables store the Cloudflare zone and authentication details.
variable "cloudflare_api_token" {
  description = "API token for accessing the Cloudflare account."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain in Cloudflare."
  type        = string
}

# These variables allow flexibility in specifying domain names, 
# S3 bucket details (if applicable), and CloudFront settings.

variable "domain_name" {
  description = "The primary domain name for the application (e.g., example.com)."
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain name for the application (e.g., www.example.com)."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket used as the CloudFront origin (if applicable)."
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket (if applicable)."
  type        = string
}


