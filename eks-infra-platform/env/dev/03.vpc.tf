#-----------------------------------------------------------------------------#
###                         VPC Component                                   ###
#-----------------------------------------------------------------------------#
module "vpc" {
  source = "../../../modules/network/vpc"

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
  # interface_endpoint_sg_id = module.interface_endpoint_sg.sg_id
  enable_eks_cluster_tags  = var.vpc["enable_eks_cluster_tags"]
  enable_internal_elb_tags = var.vpc["enable_internal_elb_tags"]
  enable_external_elb_tags = var.vpc["enable_external_elb_tags"]
}
#-----------------------------------------------------------------------------#
###                           Security Groups                               ###
#-----------------------------------------------------------------------------#