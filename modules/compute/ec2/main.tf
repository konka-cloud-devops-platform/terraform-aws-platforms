locals {
  prefix = "${var.common_tags["Environment"]}-${var.common_tags["Project"]}-${var.instance_name}"
}

resource "aws_instance" "example" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  monitoring             = var.monitoring
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.iam_instance_profile

  
  user_data = var.user_data != null ? var.user_data : null

  # Optional: ensure script re-runs if changed
  user_data_replace_on_change = true

  tags = merge(
    {
      Name = local.prefix
    },
    var.common_tags
  )
}
resource "aws_route53_record" "www" {
  count   = var.create_route53_record ? 1 : 0
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"
  ttl     = 60
  records = [aws_instance.example.public_ip]
}