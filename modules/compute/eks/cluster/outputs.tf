output "cluster_arn" {
  value = aws_eks_cluster.example.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "cluster_id" {
  value = aws_eks_cluster.example.id
}