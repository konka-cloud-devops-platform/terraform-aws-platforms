locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
}
resource "aws_eks_cluster" "example" {
  name = "${local.prefix}-eks-cluster"

  access_config {
    authentication_mode = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids = var.cluster_security_group_ids
    public_access_cidrs = var.public_access_cidrs
    subnet_ids = var.cluster_subnet_ids
  }
  enabled_cluster_log_types = var.enabled_cluster_log_types
  deletion_protection = var.deletion_protection
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-eks-cluster"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}


resource "aws_launch_template" "node" {
  for_each = var.node_groups
  name = "${local.prefix}-nodegroup-launch-template"

  vpc_security_group_ids = var.ng_security_group_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
    }
  }
  key_name = "siva"

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name = "${local.prefix}-ng-${each.key}"
      }
    )
  }
  lifecycle {
   create_before_destroy = true
  }
}
# NodeGroup
resource "aws_eks_node_group" "example" {
  for_each = var.node_groups
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.ng_subnet_ids
  capacity_type = each.value["capacity_type"]
  instance_types = each.value["instance_type"]
  scaling_config {
    desired_size = each.value["desired_size"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = "$Latest"
  }

  update_config {
    max_unavailable = 1
  }
}



