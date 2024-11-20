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
