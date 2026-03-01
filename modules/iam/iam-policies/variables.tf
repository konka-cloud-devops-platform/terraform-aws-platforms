variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}
variable "policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    description = string
    policy_json = string
  }))
}