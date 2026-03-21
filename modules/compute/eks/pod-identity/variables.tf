variable "namespace" {
  description = "K8s Namespaces"
  type = string
}
variable "service_account_name" {
  description = "K8s Service Account Name"
  type        = string
}
variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}
variable "role_arn" {
  description = "Enter role arn"
  type = string
}