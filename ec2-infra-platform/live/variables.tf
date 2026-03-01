variable "common_vars" {
  description = "Common variables for the project"
  type = object({
    aws_region  = string
    common_tags = map(string)
    zone_id     = string
  })
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    vpc_cidr_block           = string
    availability_zone        = list(string)
    web_subnet_cidr_blocks   = list(string)
    app_subnet_cidr_blocks   = list(string)
    db_subnet_cidr_blocks    = list(string)
    enable_nat_gateway       = bool
    enable_vpc_flow_logs_cw  = bool
    enable_vpc_endpoints     = bool
    enable_eks_cluster_tags  = bool
    enable_internal_elb_tags = bool
    enable_external_elb_tags = bool
    vpc_endpoints = map(object({
      service = string
      type    = string # Gateway | Interface
      enabled = bool
    }))
  })
}


variable "sg" {
  description = "SG configuration"
  type = object({
    bastion_sg_name              = string
    bastion_sg_description       = string
    vpn_sg_name                  = string
    vpn_sg_description           = string
    rds_sg_name                  = string
    rds_sg_description           = string
    elastic_cache_sg_name        = string
    elastic_cache_sg_description = string
    backend_sg_name              = string
    backend_sg_description       = string
    frontend_sg_name             = string
    frontend_sg_description      = string
    internal_alb_sg_name         = string
    internal_alb_sg_description  = string
    external_alb_sg_name         = string
    external_alb_sg_description  = string
  })
}

variable "sg_rules" {
  description = "Security group ingress and egress rules"
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    description = string

    security_group_name        = string
    source_security_group_name = optional(string)
    cidr_blocks                = optional(list(string))
    self                       = optional(bool)
  }))
}

variable "iam_role" {
  description = "IAM role for backend and frontend"
  type = object({
    backend_role_name  = string
    frontend_role_name = string
    bastion_role_name  = string
    # vpn_role_name      = string
  })
}

variable "acm" {
  description = "ACM configuration for ALB and CloudFront"
  type = object({
    lb_domain_name               = string
    lb_validation_method         = string
    cloudfront_domain_name       = string
    cloudfront_validation_method = string
  })
}

variable "rds" {
  description = "RDS"
  type = object({
    allocated_storage   = number
    engine              = string
    engine_version      = string
    instance_class      = string
    publicly_accessible = bool
    skip_final_snapshot = bool
    storage_type        = string
    rds_record_name     = string
    record_type         = string
    ttl                 = string
  })
}

variable "elastic_cache" {
  description = "Elastic Cache"
  type = object({
    engine                  = string
    major_engine_version    = string
    elasticache_record_name = string
    record_type             = string
    ttl                     = string
  })
}

variable "bastion" {
  description = "Bastion Host"
  type = object({
    volume_size   = number
    instance_name = string
    instance_type = string
    monitoring    = bool
    key_name      = string
  })
}
# variable "vpn" {
#   description = "VPN"
#   type = object({
#     volume_size   = number
#     instance_name = string
#     instance_type = string
#     monitoring    = bool
#     key_name      = string
#   })
# }

variable "internal_alb" {
  description = "Internal ALB Configuration"
  type = object({
    lb_name                    = string
    enable_deletion_protection = bool
    choose_internal_external   = bool
    enable_zonal_shift         = bool
    tg_port                    = number
    health_check_path          = string
    enable_http                = bool
    enable_https               = bool
    record_name                = string
    load_balancer_type         = string
  })
}

variable "external_alb" {
  description = "External ALB Configuration"
  type = object({
    lb_name                    = string
    enable_deletion_protection = bool
    choose_internal_external   = bool
    enable_zonal_shift         = bool
    tg_port                    = number
    health_check_path          = string
    enable_http                = bool
    enable_https               = bool
    record_name                = string
    load_balancer_type         = string
  })
}