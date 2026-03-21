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
  depends_on = [module.vpc]
  source     = "../../modules/network/sg_rules"
  rules      = local.resolved_sg_rules
}

#--------------------------------------------------------------------------------#
###                            IAM Roles                                       ###
#--------------------------------------------------------------------------------#

module "iam_roles" {

  source = "../../modules/iam"

  for_each = var.iam_roles

  role_name       = each.value.role_name
  trusted_service = each.value.trusted_service

  policy_arns = each.value.policy_arns
  inline_policies = {
    for k, v in each.value.inline_policies :
    k => file("${path.module}/../env/dev/${v}")
  }
  common_tags = var.common_vars["common_tags"]
}


#--------------------------------------------------------------------------------#
###                                EKS Module                                  ###
#--------------------------------------------------------------------------------#

module "eks_module" {
  depends_on                                  = [module.vpc]
  source                                      = "../../modules/compute/eks/cluster"
  common_tags                                 = var.common_vars["common_tags"]
  cluster_role_arn                            = module.iam_roles["eks_cluster"].role_arn
  node_role_arn                               = module.iam_roles["eks_node"].role_arn
  cluster_subnet_ids                          = module.vpc.web_subnet_ids
  cluster_security_group_ids                  = [module.controlplane.sg_id]
  ng_security_group_ids                       = [module.nodegroup.sg_id]
  ng_subnet_ids                               = module.vpc.web_subnet_ids
  authentication_mode                         = var.eks["authentication_mode"]
  cluster_version                             = var.eks["cluster_version"]
  endpoint_private_access                     = var.eks["endpoint_private_access"]
  endpoint_public_access                      = var.eks["endpoint_public_access"]
  enabled_cluster_log_types                   = var.eks["enabled_cluster_log_types"]
  bootstrap_cluster_creator_admin_permissions = var.eks["bootstrap_cluster_creator_admin_permissions"]
  deletion_protection                         = var.eks["deletion_protection"]
  public_access_cidrs                         = var.eks["public_access_cidrs"]
  node_groups                                 = var.eks["node_groups"]
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks_module.cluster_id
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  depends_on = [module.eks_module]
}

module "addons" {
  depends_on    = [module.eks_module]
  source        = "../../modules/compute/eks/addons"
  for_each      = var.addons
  cluster_name  = module.eks_module.cluster_id
  addon_name    = each.key
  addon_version = each.value
}

module "pod_identity" {
  for_each             = var.pod_identity
  depends_on           = [module.eks_module]
  source               = "../../modules/compute/eks/pod-identity"
  cluster_name         = module.eks_module.cluster_id
  namespace            = each.value.namespace
  service_account_name = each.value.service_account_name
  role_arn             = module.iam_roles[each.value.iam_role_key].role_arn
}

