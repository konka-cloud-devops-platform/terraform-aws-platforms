data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}-${var.identity_name}-pod-identity-role"
}

resource "aws_iam_role" "example" {
  name               = local.prefix
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


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