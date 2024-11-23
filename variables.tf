variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "verified_sender_email" {
  description = "Verified email address for SES"
  type        = string
  default     = "sam.albershtein@gmail.com" # Replace with your SES verified email
}

variable "cloudfront_private_key" {
  description = "CloudFront private key in PEM format"
  type        = string
  sensitive   = true
}

/*
Purpose of sensitive = true
Hides sensitive output: When a variable is marked as sensitive, Terraform ensures that its value is not displayed in logs, outputs, or in the Terraform state file where possible. 
This reduces the risk of accidentally exposing sensitive data, such as private keys, passwords, or tokens.

Prevents accidental exposure:

If you try to output this variable in your Terraform configuration (e.g., using an output block), Terraform will mask its value with (sensitive value) unless you explicitly handle it differently.
This prevents the value from being logged in plaintext during a terraform plan or terraform apply.
Protects compliance and security: It aligns with best practices for security by ensuring that sensitive information is not inadvertently exposed to those who might have access to Terraform logs or outputs but do not have permission to view sensitive data.
*/

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

variable "lambda_btc_api_token" {
  description = "API token for fetching BTC value from Coin Market Cap"
  type        = string
  sensitive   = true
}




