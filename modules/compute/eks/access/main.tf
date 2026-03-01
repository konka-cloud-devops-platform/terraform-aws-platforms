resource "aws_eks_access_entry" "access" {
  for_each          = var.access
  cluster_name      = var.cluster_name
  principal_arn     = each.value["principal_arn"]
  kubernetes_groups = try(each.value["kubernetes_groups"], [])
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "main" {
  for_each      = var.access
  cluster_name  = var.cluster_name
  policy_arn    = each.value["policy_arn"]
  principal_arn = each.value["principal_arn"]

  access_scope {
    type       = each.value["access_scope"]
    namespaces = each.value["access_scope"] == "cluster" ? [] : try(each.value["namespaces"], [])
  }
}