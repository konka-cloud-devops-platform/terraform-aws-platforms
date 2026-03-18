variable "common_tags" {
  description = "Common tags to be applied to all IAM resources"
  type        = map(string)
  default     = {}
}
variable "role_name" {
  type = string
}

variable "trusted_service" {
  type    = string
  default = null
}

variable "policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type    = map(string)
  default = {}
}