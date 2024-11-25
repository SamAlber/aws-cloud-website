output "website_bucket_name" {
  value       = aws_s3_bucket.website_bucket.bucket
  description = "Name of the website S3 bucket"
}

output "api_gateway_invoke_url" {
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "Invoke URL for the API Gateway"
}

# The CloudFront distribution domain name is needed to create the final DNS records in Cloudflare.
output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "Domain name of the CloudFront distribution"
}
/*
This will output a list of objects containing:

resource_record_name: The CNAME record name.
resource_record_type: The record type (usually CNAME).
resource_record_value: The value for the CNAME record.

*/

# Output the ARN of the certificate
output "acm_arn" {
  value = aws_acm_certificate.cert_for_cloudflare_dns.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert_for_cloudflare_dns.domain_validation_options
}
