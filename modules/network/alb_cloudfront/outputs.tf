output "domain_name" {
  description = "value of the domain name for the CloudFront distribution"
    value       = aws_cloudfront_distribution.distribution.domain_name
}

output "cdn_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.id
}