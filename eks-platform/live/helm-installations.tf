# Karpenter Helm Chart Installation
resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.10.0"
  wait       = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks_module.cluster_id}
      clusterEndpoint: ${module.eks_module.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]
  depends_on = [module.eks_module]

}

# Karpenter EC2NodeClass Manifest

resource "kubernetes_manifest" "karpenter_ec2_nodeclass" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "${module.eks_module.cluster_id}-nc"
    }
    spec = {
      amiSelectorTerms = [{
        alias = "al2023@latest"
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = module.eks_module.cluster_id
        }
      }]
      securityGroupSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = module.eks_module.cluster_id
        }
      }]
      role = module.karpenter.node_iam_role_name # Changed from instanceProfile to role
      tags = {
        "Name" = "${module.eks_module.cluster_id}-karpenter-worker"
      }
    }
  }
  depends_on = [helm_release.karpenter, module.eks_module]
}