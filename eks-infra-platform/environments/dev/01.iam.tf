module "eks-iam" {
  source      = "../../../modules/eks/iam-eks"
  common_tags = var.common_vars["common_tags"]
}