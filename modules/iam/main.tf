locals {
  name = "${title(replace(var.common_tags["Environment"], "-", ""))}${title(replace(var.common_tags["Project"], "-", ""))}${title(replace(var.role_name, "-", ""))}"
}
resource "aws_iam_role" "role" {

  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = var.trusted_service
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
  tags = merge(
    var.common_tags,
    {
      Name = local.name
    }
  )
}

resource "aws_iam_role_policy_attachment" "managed" {

  for_each = toset(var.policy_arns)

  role       = aws_iam_role.role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {

  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.role.id
  policy = each.value
}

