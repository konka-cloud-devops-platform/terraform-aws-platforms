variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}


variable "namespace" {
  description = "K8s Namespaces"
  type = string
}

variable "service_account_name" {
  description = "K8s Service Account Name"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM Policy ARNs to attach to the role"
  type = list(string)
}
variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}