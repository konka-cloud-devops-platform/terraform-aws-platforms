locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
}
resource "aws_iam_policy" "this" {
  for_each = var.policies
  name        = "${local.prefix}-${each.key}"
  description = each.value.description
  policy      = each.value.policy_json
}