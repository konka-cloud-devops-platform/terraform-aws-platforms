module "bastion" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["bastion_sg_name"]
  sg_description = var.sg["bastion_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "vpn" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["vpn_sg_name"]
  sg_description = var.sg["vpn_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "rds" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["rds_sg_name"]
  sg_description = var.sg["rds_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "elasticache" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["elasticache_sg_name"]
  sg_description = var.sg["elasticache_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "controlplane" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["controlplane_sg_name"]
  sg_description = var.sg["controlplane_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "nodegroup" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["nodegroup_sg_name"]
  sg_description = var.sg["nodegroup_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "external_alb" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["external_alb_sg_name"]
  sg_description = var.sg["external_alb_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "interface_endpoint_sg" {
  source         = "../../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["interface_endpoint_sg_name"]
  sg_description = var.sg["interface_endpoint_sg_description"]
  vpc_id         = module.vpc.vpc_id
}

module "sg_rules" {
  source = "../../../modules/network/sg_rules"
  rules  = local.resolved_sg_rules
}