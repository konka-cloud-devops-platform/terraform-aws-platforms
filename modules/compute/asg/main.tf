locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
}
resource "aws_launch_template" "foo" {
  name = local.prefix
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 15
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    name = var.instance_profile
  } 

  image_id = var.image_id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_type

  key_name = var.key_name

  

  monitoring {
    enabled = var.monitoring_enable
  }

  vpc_security_group_ids = var.security_groups

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = local.prefix
      },
      var.common_tags
    )
  }

   user_data =  base64encode(var.user_data)

}

resource "aws_autoscaling_group" "bar" {
  name                      = "${local.prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  target_group_arns         = var.target_group_arns
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  dynamic "tag" {
    for_each = merge(
      { 
        Name = local.prefix
      },
      var.common_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "aap" {
  name                   = local.prefix
  autoscaling_group_name = aws_autoscaling_group.bar.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.target_value
  }
}