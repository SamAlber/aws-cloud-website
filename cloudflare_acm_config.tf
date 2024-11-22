resource "aws_acm_certificate" "cert_for_cloudflare_dns" {
  domain_name       = "www.samuelalber.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "samuelalber.com" # Add the second domain here
  ]
}

resource "cloudflare_dns_record" "cdn_records" {
  for_each = {
    "root" = {
      name  = "samuelalber.com"
      content = aws_cloudfront_distribution.cdn.domain_name
      type  = "CNAME"
    }
    "www" = {
      name  = "www.samuelalber.com"
      content = aws_cloudfront_distribution.cdn.domain_name
      type  = "CNAME"
    }
  }

  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  zone_id = var.cloudflare_zone_id
  ttl     = 300
}

resource "cloudflare_dns_record" "acm_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.cert_for_cloudflare_dns.domain_validation_options : dvo.domain_name => {
      name    = replace(dvo.resource_record_name, "/\\.$/", "")
      content = replace(dvo.resource_record_value, "/\\.$/", "")
      type    = dvo.resource_record_type
    }
  }

  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  zone_id = var.cloudflare_zone_id
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert_for_cloudflare_dns" {
  certificate_arn = aws_acm_certificate.cert_for_cloudflare_dns.arn

  validation_record_fqdns = [
    for record in cloudflare_dns_record.acm_validation_records : record.name
  ]
}

/*
data "cloudflare_dns_record" "cert_for_cloudflare_dns" {
  filter = {
  name = "samuelalber.com" # The record name
  type = "CNAME"           # The record type (e.g., CNAME, A, TXT)
  zone_id = var.cloudflare_zone_id
  }
}

This block is not needed because it attempts to query an existing DNS record in Cloudflare. Since no records are configured, this block will always fail.
*/

/*
The data "cloudflare_dns_record" block in Terraform is used to query existing DNS records in your Cloudflare account. 
It allows you to fetch details about a DNS record in a specific zone (e.g., example.com) and use that information in other parts of your Terraform configuration.*/
/*

Cloudflare is your DNS provider: You're not hosting DNS records in Route 53, 
so you don't need to configure anything in AWS Route 53.
CNAME Validation in Cloudflare: ACM provides CNAME records for validation, 
and these can be directly added to your Cloudflare DNS.
*/

/* 

I GAVE UP ON THIS ! 

the goal is to create DNS records in Cloudflare to validate your domain ownership for the AWS ACM certificate. Specifically, AWS ACM requires CNAME records to be added to your DNS provider (in this case, Cloudflare) to complete the DNS validation process.
resource "cloudflare_dns_record" "records_for_cloudflare_dns" {
  depends_on = [aws_acm_certificate.cert_for_cloudflare_dns]
  for_each = {
    for dvo in aws_acm_certificate.cert_for_cloudflare_dns.domain_validation_options : dvo.domain_name => {
      name   = replace(dvo.resource_record_name, "/\\.$/", "")
      record = replace(dvo.resource_record_value, "/\\.$/", "") # dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  ttl             = 60
  type            = each.value.type
  zone_id         = var.cloudflare_zone_id 
}
*/

# ----- # 

# E.g: 
/* 
[
  "_abc123.samuelalber.com",
  "_def456.samuelalber.com"
]
This list is then passed to the validation_record_fqdns attribute of the aws_acm_certificate_validation resource.
*/

