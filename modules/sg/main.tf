locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}-${var.sg_name}"
}

resource "aws_security_group" "sg" {
  name        = local.prefix
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-sg"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}