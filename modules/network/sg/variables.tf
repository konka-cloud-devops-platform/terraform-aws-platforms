variable "sg_name" {
  description = "Name of SG"
  type = string
}
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "Enter VPC_ID"
  type = string
}

variable "sg_description" {
  description = "Enter Description of SG"
  type = string
}