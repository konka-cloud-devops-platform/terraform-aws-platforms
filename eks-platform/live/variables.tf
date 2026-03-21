variable "common_vars" {
  description = "Common variables for the project"
  type = object({
    aws_region  = string
    common_tags = map(string)
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
    rds_sg_name                       = string
    rds_sg_description                = string
    elasticache_sg_name               = string
    elasticache_sg_description        = string
    controlplane_sg_name              = string
    controlplane_sg_description       = string
    nodegroup_sg_name                 = string
    nodegroup_sg_description          = string
    external_alb_sg_name              = string
    external_alb_sg_description       = string
    interface_endpoint_sg_name        = string
    interface_endpoint_sg_description = string
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

variable "iam_roles" {
  type = map(object({
    role_name       = string
    trusted_service = string
    policy_arns     = list(string)
    inline_policies = map(string)
  }))
}

variable "eks" {
  description = "EKS cluster configuration"
  type = object({
    authentication_mode                         = string
    cluster_version                             = string
    endpoint_private_access                     = bool
    endpoint_public_access                      = bool
    enabled_cluster_log_types                   = list(string)
    bootstrap_cluster_creator_admin_permissions = bool
    deletion_protection                         = bool
    public_access_cidrs                         = list(string)
    node_groups = map(object({
      instance_type = list(string)
      desired_size  = number
      max_size      = number
      min_size      = number
      capacity_type = string
    }))
  })
}
variable "addons" {
  description = "EKS addons configuration"
  type        = map(string)
}

variable "pod_identity" {
  description = "EKS Pod Identity configuration"
  type = map(object({
    namespace            = string
    service_account_name = string
    iam_role_key         = string
  }))
}