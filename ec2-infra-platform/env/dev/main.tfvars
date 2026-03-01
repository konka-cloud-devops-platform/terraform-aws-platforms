#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                      Common Values                           #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
common_vars = {
  aws_region = "ap-south-1"
  zone_id    = "Z05358812YCB33LWR8F1V"
  common_tags = {
    Owner       = "konka"
    Environment = "dev"
    Project     = "carvo"
  }
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                        VPC Values                            #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

vpc = {
  vpc_cidr_block           = "172.31.0.0/16"
  availability_zone        = ["ap-south-1a", "ap-south-1b"]
  web_subnet_cidr_blocks   = ["172.31.1.0/24", "172.31.2.0/24"]
  app_subnet_cidr_blocks   = ["172.31.10.0/24", "172.31.20.0/24"]
  db_subnet_cidr_blocks    = ["172.31.100.0/24", "172.31.110.0/24"]
  enable_nat_gateway       = false
  enable_vpc_flow_logs_cw  = false
  enable_vpc_endpoints     = false
  enable_eks_cluster_tags  = false
  enable_internal_elb_tags = false
  enable_external_elb_tags = false
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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                    SG Values & Rules                         #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

sg = {
  bastion_sg_name                   = "bastion"
  bastion_sg_description            = "SG for Bastion"
  vpn_sg_name                       = "vpn"
  vpn_sg_description                = "SG for VPN"
  rds_sg_name                       = "rds"
  rds_sg_description                = "SG for RDS"
  elastic_cache_sg_name               = "elastic-cache"
  elastic_cache_sg_description        = "SG for Elastic Cahe"
  backend_sg_name                   = "backend"
  backend_sg_description            = "SG for Backend"
  frontend_sg_name                  = "frontend"
  frontend_sg_description           = "SG for Frontend"
  external_alb_sg_name              = "external-alb"
  external_alb_sg_description       = "SG for External ALB"
  internal_alb_sg_name              = "internal-alb"
  internal_alb_sg_description       = "SG for Internal ALB"
}

sg_rules = {
  # -----------------------#
  # Bastion SG Rules       #
  # -----------------------#
  bastion_ssh = {
    type                = "ingress"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    description         = "Allow SSH access from anywhere"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "bastion"
  }

  # -----------------------#
  # VPN SG Rules           #
  # -----------------------#
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

  # -----------------------#
  # RDS SG Rules           #
  # -----------------------#
  vpn_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "Allow MySQL (3306) access to RDS from VPN instances"
    security_group_name        = "rds"
    source_security_group_name = "vpn"
  }

  bastion_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "Allow MySQL (3306) access to RDS from Bastion host"
    security_group_name        = "rds"
    source_security_group_name = "bastion"
  }

  backend_rds = {
    type                       = "ingress"
    from_port                  = 3306
    to_port                    = 3306
    protocol                   = "tcp"
    description                = "Allow MySQL (3306) access to RDS from Backend application"
    security_group_name        = "rds"
    source_security_group_name = "backend"
  }


  # -----------------------#
  # ElastiCache SG Rules   #
  # -----------------------#
  bastion_elasticache = {
    type                       = "ingress"
    from_port                  = 6379
    to_port                    = 6379
    protocol                   = "tcp"
    description                = "Allow Redis (6379) access to ElastiCache from Bastion host"
    security_group_name        = "elasticache"
    source_security_group_name = "bastion"
  }

  backend_elasticache = {
    type                       = "ingress"
    from_port                  = 6379
    to_port                    = 6379
    protocol                   = "tcp"
    description                = "Allow Redis (6379) access to ElastiCache from Backend application"
    security_group_name        = "elasticache"
    source_security_group_name = "backend"
  }


  # -----------------------#
  # Backend SG Rules       #
  # -----------------------#
  vpn_backend = {
    type                       = "ingress"
    from_port                  = 8080
    to_port                    = 8080
    protocol                   = "tcp"
    description                = "Allow HTTP application traffic (8080) to Backend from VPN"
    security_group_name        = "backend"
    source_security_group_name = "vpn"
  }

  bastion_backend = {
    type                       = "ingress"
    from_port                  = 8080
    to_port                    = 8080
    protocol                   = "tcp"
    description                = "Allow HTTP application traffic (8080) to Backend from Bastion host"
    security_group_name        = "backend"
    source_security_group_name = "bastion"
  }

  internal_alb_backend = {
    type                       = "ingress"
    from_port                  = 8080
    to_port                    = 8080
    protocol                   = "tcp"
    description                = "Allow traffic from Internal ALB to Backend service on port 8080"
    security_group_name        = "backend"
    source_security_group_name = "internal_alb"
  }

  bastion_ssh_backend = {
    type                       = "ingress"
    from_port                  = 22
    to_port                    = 22
    protocol                   = "tcp"
    description                = "Allow SSH access to Backend instances from Bastion host"
    security_group_name        = "backend"
    source_security_group_name = "bastion"
  }

  vpn_ssh_backend = {
    type                       = "ingress"
    from_port                  = 22
    to_port                    = 22
    protocol                   = "tcp"
    description                = "Allow SSH access to Backend instances from VPN network"
    security_group_name        = "backend"
    source_security_group_name = "vpn"
  }

  # -----------------------#
  # Internal ALB SG Rules  #
  # -----------------------#
  vpn_internal_alb = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic to Internal ALB from VPN network"
    security_group_name        = "internal_alb"
    source_security_group_name = "vpn"
  }

  bastion_internal_alb = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic to Internal ALB from Bastion host"
    security_group_name        = "internal_alb"
    source_security_group_name = "bastion"
  }

  frontend_internal_alb = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic to Internal ALB from Frontend service"
    security_group_name        = "internal_alb"
    source_security_group_name = "frontend"
  }

  # -----------------------#
  # Frontend SG Rules      #
  # -----------------------#
  vpn_frontend = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic to Frontend service from VPN network"
    security_group_name        = "frontend"
    source_security_group_name = "vpn"
  }

  bastion_frontend = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic to Frontend service from Bastion host"
    security_group_name        = "frontend"
    source_security_group_name = "bastion"
  }

  external_alb_frontend = {
    type                       = "ingress"
    from_port                  = 80
    to_port                    = 80
    protocol                   = "tcp"
    description                = "Allow HTTP traffic from External ALB to Frontend service"
    security_group_name        = "frontend"
    source_security_group_name = "external_alb"
  }

  bastion_ssh_frontend = {
    type                       = "ingress"
    from_port                  = 22
    to_port                    = 22
    protocol                   = "tcp"
    description                = "Allow SSH access to Frontend instances from Bastion host"
    security_group_name        = "frontend"
    source_security_group_name = "bastion"
  }

  vpn_ssh_frontend = {
    type                       = "ingress"
    from_port                  = 22
    to_port                    = 22
    protocol                   = "tcp"
    description                = "Allow SSH access to Frontend instances from VPN network"
    security_group_name        = "frontend"
    source_security_group_name = "vpn"
  }


  # -----------------------#
  # External ALB SG Rules  #
  # -----------------------#
  http_external_external_alb = {
    type                = "ingress"
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    description         = "Allow public HTTP traffic from internet to External ALB"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "external_alb"
  }

  https_external_external_alb = {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    description         = "Allow public HTTPS traffic from internet to External ALB"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_name = "external_alb"
  }

}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                    IAM Roles Values                          #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
iam_role = {
  backend_role_name  = "backend"
  frontend_role_name = "frontend"
  bastion_role_name  = "bastion"
  vpn_role_name      = "vpn"
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                     acm Certificates                         #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

acm = {
  lb_domain_name             = "dev-frontend.konka.online"
  lb_validation_method       = "DNS"
  cloudfront_domain_name     = "dev-carvo.konka.online"
  cloudfront_validation_method = "DNS"
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                          RDS Values                          #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
rds = {
  allocated_storage   = "20"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  publicly_accessible = false
  skip_final_snapshot = true
  storage_type        = "gp3"
  rds_record_name     = "dev-rds"
  record_type         = "CNAME"
  ttl                 = "60"
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                        Elastic Cache                         #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
elastic_cache = {
  engine                  = "valkey"
  major_engine_version    = "8"
  elasticache_record_name = "dev-elasticache"
  record_type             = "CNAME"
  ttl                     = "60"
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                             Bastion                          #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
bastion = {
  volume_size                    = 10
  instance_name                  = "bastion"
  instance_type                  = "t3a.micro"
  monitoring                     = false
  key_name                       = "siva"
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                               VPN                            #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# vpn = {
#   volume_size                    = 10
#   instance_name                  = "vpn"
#   instance_type                  = "t3a.small"
#   monitoring                     = false
#   key_name                       = "siva"
# }
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                   Internal & External ALB                    #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
internal_alb = {
  lb_name                    = "backned"
  enable_deletion_protection = false
  choose_internal_external   = true
  enable_zonal_shift         = false
  load_balancer_type         = "application"
  tg_port                    = 8080
  health_check_path          = "/health"
  enable_http                = true
  enable_https               = false
  record_name                = "dev-backend.konka.online"
}

external_alb = {
  lb_name                    = "frontend"
  enable_deletion_protection = false
  choose_internal_external   = false
  enable_zonal_shift         = false
  load_balancer_type         = "application"
  tg_port                    = 80
  health_check_path          = "/"
  enable_http                = false
  enable_https               = true
  record_name                = "dev-frontend.konka.online"
}