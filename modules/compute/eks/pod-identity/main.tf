resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.policy_arns)

  role       = aws_iam_role.example.name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.example.arn
}