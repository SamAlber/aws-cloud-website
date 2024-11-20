output "website_bucket_name" {
  value       = aws_s3_bucket.website_bucket.bucket
  description = "Name of the website S3 bucket"
}

output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "Domain name of the CloudFront distribution"
}

output "api_gateway_invoke_url" {
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "Invoke URL for the API Gateway"
}
