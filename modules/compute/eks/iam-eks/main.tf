locals {
  prefix = "${var.common_tags["Project"]}-${var.common_tags["Environment"]}"
  node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
  cluster_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  ]
}

##############################################################################
################ Control Plane IAM Role for EKS Cluster ######################
##############################################################################
resource "aws_iam_role" "cluster" {
  name = "${local.prefix}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-eks-cluster-role"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each   = toset(local.cluster_policies)
  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}
##############################################################################
############################ Node Group IAM Role for EKS #####################
##############################################################################

resource "aws_iam_role" "node" {
  name = "${local.prefix}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(
    var.common_tags,
    {
      Name = "${local.prefix}-eks-node-role"
      Environment = var.common_tags["Environment"]
      Project     = var.common_tags["Project"]
    }
  )
}

resource "aws_iam_role_policy_attachment" "node" {
    for_each   = toset(local.node_policies)
    policy_arn = each.value
    role       = aws_iam_role.node.name
}

