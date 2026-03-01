#--------------------------------------------------------------------------------#
###                            VPC Components                                  ###
#--------------------------------------------------------------------------------#
module "vpc" {
  source = "../../modules/network/vpc"

  vpc_cidr_block = var.vpc["vpc_cidr_block"]

  availability_zone = var.vpc["availability_zone"]

  web_subnet_cidr_blocks = var.vpc["web_subnet_cidr_blocks"]
  app_subnet_cidr_blocks = var.vpc["app_subnet_cidr_blocks"]
  db_subnet_cidr_blocks  = var.vpc["db_subnet_cidr_blocks"]

  enable_nat_gateway      = var.vpc["enable_nat_gateway"]
  enable_vpc_flow_logs_cw = var.vpc["enable_vpc_flow_logs_cw"]

  common_tags              = var.common_vars["common_tags"]
  region                   = var.common_vars["aws_region"]
  enable_vpc_endpoints     = var.vpc["enable_vpc_endpoints"]
  vpc_endpoints            = var.vpc["vpc_endpoints"]
  interface_endpoint_sg_id = module.interface_endpoint_sg.sg_id
  enable_eks_cluster_tags  = var.vpc["enable_eks_cluster_tags"]
  enable_internal_elb_tags = var.vpc["enable_internal_elb_tags"]
  enable_external_elb_tags = var.vpc["enable_external_elb_tags"]
}

#--------------------------------------------------------------------------------#
###                            Security Groups                                 ###
#--------------------------------------------------------------------------------#

module "bastion" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["bastion_sg_name"]
  sg_description = var.sg["bastion_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "vpn" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["vpn_sg_name"]
  sg_description = var.sg["vpn_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "rds" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["rds_sg_name"]
  sg_description = var.sg["rds_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "elasticache" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["elasticache_sg_name"]
  sg_description = var.sg["elasticache_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "controlplane" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["controlplane_sg_name"]
  sg_description = var.sg["controlplane_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "nodegroup" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["nodegroup_sg_name"]
  sg_description = var.sg["nodegroup_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "external_alb" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["external_alb_sg_name"]
  sg_description = var.sg["external_alb_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "interface_endpoint_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["interface_endpoint_sg_name"]
  sg_description = var.sg["interface_endpoint_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "sg_rules" {
  source = "../../modules/network/sg_rules"
  rules  = local.resolved_sg_rules
}


