variable "common_tags" {
  description = "Common tags to be applied to all IAM resources"
  type        = map(string)
  default     = {}
}
variable "role_name" {
  description = "The name of the IAM role to be created"
  type        = string
}
variable "policy_file" {
  description = "The path to the IAM policy file in JSON format"
  type        = string
}