module "eks_cluster" {
  source                                      = "../../../modules/eks/cluster"
  cluster_role_arn                            = module.eks-iam.cluster_arn
  cluster_subnet_ids                          = module.vpc.web_subnet_ids
  cluster_security_group_ids                  = [module.controlplane.sg_id]
  ng_security_group_ids                       = [module.nodegroup.sg_id]
  ng_subnet_ids                               = module.vpc.web_subnet_ids
  node_role_arn                               = module.eks-iam.node_arn
  common_tags                                 = var.common_vars["common_tags"]
  node_groups                                 = var.eks["node_groups"]
  authentication_mode                         = var.eks["authentication_mode"]
  cluster_version                             = var.eks["cluster_version"]
  endpoint_private_access                     = var.eks["endpoint_private_access"]
  endpoint_public_access                      = var.eks["endpoint_public_access"]
  enabled_cluster_log_types                   = var.eks["enabled_cluster_log_types"]
  bootstrap_cluster_creator_admin_permissions = var.eks["bootstrap_cluster_creator_admin_permissions"]
  deletion_protection                         = var.eks["deletion_protection"]
  public_access_cidrs                         = var.eks["public_access_cidrs"]
}

module "eks_addons" {
  source        = "../../../modules/eks/addons"
  for_each      = var.addons
  cluster_name  = module.eks_cluster.cluster_id
  addon_name    = each.key
  addon_version = each.value
  depends_on    = [module.eks_cluster]
}