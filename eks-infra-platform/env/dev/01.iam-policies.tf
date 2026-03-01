module "iam_policies" {
  source = "../../../modules/iam-policies"
  policies = {
    ebs-csi-policy = {
      description = "Policy for EBS CSI driver"
      policy_json = file("${path.module}/policies/ebs-csi-policy.json")
    }
  }
  common_tags = var.common_vars["common_tags"]
}