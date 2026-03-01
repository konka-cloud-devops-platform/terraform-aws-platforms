common_vars = {
  aws_region = "ap-south-1"
  common_tags = {
    Owner       = "konka"
    Environment = "dev"
    Project     = "moneylag"
  }
}

vpc = {
  vpc_cidr_block           = "10.0.0.0/16"
  availability_zone        = ["ap-south-1a", "ap-south-1b"]
  web_subnet_cidr_blocks   = ["10.0.1.0/24", "10.0.2.0/24"]
  app_subnet_cidr_blocks   = ["10.0.10.0/24", "10.0.20.0/24"]
  db_subnet_cidr_blocks    = ["10.0.100.0/24", "10.0.110.0/24"]
  enable_nat_gateway       = false
  enable_vpc_flow_logs_cw  = false
  enable_vpc_endpoints     = false
  enable_eks_cluster_tags  = true
  enable_internal_elb_tags = true
  enable_external_elb_tags = true
  vpc_endpoints = {
    s3_backup = {
      service = "s3"
      type    = "Gateway"
      enabled = true
    }
    ecr_api = {
      service = "ecr.api"
      type    = "Interface"
      enabled = true
    }
  }
}

sg = {
  bastion_sg_name                   = "bastion"
  bastion_sg_description            = "Security group for bastion hosts"
  vpn_sg_name                       = "vpn"
  vpn_sg_description                = "Security group for VPN"
  rds_sg_name                       = "rds"
  rds_sg_description                = "Security group for RDS instances"
  elasticache_sg_name               = "elasticache"
  elasticache_sg_description        = "Security group for ElastiCache"
  controlplane_sg_name              = "controlplane"
  controlplane_sg_description       = "Security group for EKS control plane"
  nodegroup_sg_name                 = "nodegroup"
  nodegroup_sg_description          = "Security group for EKS node groups"
  external_alb_sg_name              = "external_alb"
  external_alb_sg_description       = "Security group for external ALB"
  interface_endpoint_sg_name        = "interface_endpoint"
  interface_endpoint_sg_description = "Security group for VPC interface endpoints"
}

sg_rules = {

  # -----------------------
  # Bastion SG Rules
  # -----------------------
  bastion_ssh = {
    type                = "ingress"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    description         = "Allow SSH access from anywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "bastion"
  }

  # -----------------------
  # VPN SG Rules
  # -----------------------
  vpn_ssh = {
    type                = "ingress"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    description         = "This rule allows all traffic from internet on 22"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "vpn"
  }

  vpn_https = {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    description         = "This rule allows all traffic from internet on 443"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "vpn"
  }

  vpn_et = {
    type                = "ingress"
    from_port           = 943
    to_port             = 943
    protocol            = "tcp"
    description         = "This rule allows all traffic from internet on 943"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "vpn"
  }

  vpn_udp = {
    type                = "ingress"
    from_port           = 1194
    to_port             = 1194
    protocol            = "udp"
    description         = "This rule allows all traffic from internet on 1194"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "vpn"
  }

  # -----------------------
  # RDS SG Rules
  # -----------------------
  nodegroup_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "This rule allows all traffic from nodegroup to rds on 3306"
    security_group_name        = "rds"
    source_security_group_name = "nodegroup"
  }

  vpn_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "This rule allows all traffic from vpn to rds on 3306"
    security_group_name        = "rds"
    source_security_group_name = "vpn"
  }

  bastion_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "This rule allows all traffic from bastion to rds on 3306"
    security_group_name        = "rds"
    source_security_group_name = "bastion"
  }

  # -----------------------
  # ElastiCache SG Rules
  # -----------------------
  nodegroup_elasticache = {
    type                       = "ingress"
    from_port                  = 6379
    to_port                    = 6379
    protocol                   = "tcp"
    description                = "This rule allows all traffic from nodegroup to elasticache on 6379"
    security_group_name        = "elasticache"
    source_security_group_name = "nodegroup"
  }

  vpn_elasticache = {
    type                       = "ingress"
    from_port                  = 6379
    to_port                    = 6379
    protocol                   = "tcp"
    description                = "This rule allows all traffic from vpn to elasticache on 6379"
    security_group_name        = "elasticache"
    source_security_group_name = "vpn"
  }

  bastion_elasticache = {
    type                       = "ingress"
    from_port                  = 6379
    to_port                    = 6379
    protocol                   = "tcp"
    description                = "This rule allows all traffic from bastion to elasticache on 6379"
    security_group_name        = "elasticache"
    source_security_group_name = "bastion"
  }

  # -----------------------
  # Control Plane SG Rules
  # -----------------------
  external_controlplane = {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    description         = "This rule allows all traffic from external to controlplane on 443"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "controlplane"
  }

  nodegroup_controlplane = {
    type                       = "ingress"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    description                = "This rule allows all traffic from nodegroup to controlplane"
    security_group_name        = "controlplane"
    source_security_group_name = "nodegroup"
  }

  # -----------------------
  # Nodegroup SG Rules
  # -----------------------
  controlplane_nodegroup = {
    type                       = "ingress"
    from_port                  = 0
    to_port                    = 0
    protocol                   = "-1"
    description                = "This rule allows all traffic from controlplane to nodegroup"
    security_group_name        = "nodegroup"
    source_security_group_name = "controlplane"
  }


  nodegroup_self = {
    type                = "ingress"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    description         = "This rule allows all traffic from nodegroup itself"
    self                = true
    security_group_name = "nodegroup"
  }

  alb_nodegroup = {
    type                       = "ingress"
    from_port                  = 30000
    to_port                    = 32767
    protocol                   = "tcp"
    description                = "This rule allows all traffic from alb to nodegroup on nodeport range"
    security_group_name        = "nodegroup"
    source_security_group_name = "external_alb"
  }

  # -----------------------
  # ALB SG Rules
  # -----------------------
  http_alb = {
    type                = "ingress"
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    description         = "This rule allows all traffic from internet to alb on port 80"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "external_alb"
  }

  https_alb = {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    description         = "This rule allows all traffic from internet to alb on port 443"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "external_alb"
  }

  interface_endpoint = {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    description         = "This rule allows all traffic from VPC to interface endpoints"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "interface_endpoint"
  }
}
