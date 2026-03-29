locals {
  prefix = "${var.common_tags["Environment"]}-${var.common_tags["Project"]}"
  sg_name = "${local.prefix}-${var.sg_name}"
  karpenter_tags = var.enable_karpenter ? {
    "karpenter.sh/discovery" = "${local.prefix}-eks-cluster"
  } : {}
}

resource "aws_security_group" "sg" {
  name        = local.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    local.karpenter_tags,
    {
      Name = "${local.sg_name}-sg"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}