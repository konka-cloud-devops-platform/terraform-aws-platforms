variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "authentication_mode" {
  description = "Authentication mode for the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "Role for Cluster"
  type = string
}

variable "cluster_version" {
  description = "Enter version of Cluster"
  type = string
}

variable "endpoint_private_access" {
  description = "Enable private access to the EKS cluster endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS cluster endpoint"
  type        = bool
}
variable "cluster_subnet_ids" {
  description = "Enter subnets for EKS Cluster"
  type = list(string)
}

variable "enabled_cluster_log_types" {
  description = "List of enabled cluster log types"
  type        = list(string)
  default     = []
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Bootstrap cluster creator admin permissions"
  type = bool
}
variable "deletion_protection" {
  description = "Enable deletion protection for the EKS cluster"
  type        = bool
  default     = false
}
variable "cluster_security_group_ids" {
  description = "SG for Control Plane"
  type = list(string)
}

variable "public_access_cidrs" {
  description = "CIDR for Cluster Access"
  type = list(string)
}

variable "node_groups" {
  description = "EKS Node Groups configuration"
  type = map(object({
    instance_type  = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
    capacity_type  = string
  }))
}

variable "ng_security_group_ids" {
  description = "SG for node groups"
  type = list(string)
}

variable "ng_subnet_ids" {
  description = "Subnet IDs for node groups"
  type = list(string)
}

variable "node_role_arn" {
  description = "Node Role Arn for node group"
  type = string
}

variable "addons" {
  description = "EKS addons as map(addon_name => addon_version)"
  type        = map(string)
}