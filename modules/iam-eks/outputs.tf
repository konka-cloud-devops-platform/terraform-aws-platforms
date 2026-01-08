output "cluster_arn" {
  value = aws_iam_role.cluster.arn
}
output "node_arn" {
  value = aws_iam_role.node.arn
}