variable "access" {
    description = "A map of access entries to create."
    type = map(object({
        principal_arn     = string
        kubernetes_groups = optional(list(string), [])
        policy_arn        = string
        access_scope     = string
        namespaces       = optional(list(string), [])
    }))
}

variable "cluster_name" {
  description = "value"
  type = string
}