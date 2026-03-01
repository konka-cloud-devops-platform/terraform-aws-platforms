locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
}
resource "aws_cloudfront_distribution" "distribution" {

    origin {
      domain_name = var.domain_name
      origin_id = "alborigin"
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
            locations        = []
        }
    }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  default_cache_behavior {
    target_origin_id       = "alborigin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

     forwarded_values {
       query_string = true
        cookies {
          forward = "all"
        }
     }
  }

    aliases = var.aliases
    enabled = true
    default_root_object = var.default_root_object

    tags = merge(
    var.common_tags,
    {
      Name = local.prefix
    }
  )
}
resource "null_resource" "invalidate_cloudfront" {

    provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.distribution.id} --paths /*"
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}