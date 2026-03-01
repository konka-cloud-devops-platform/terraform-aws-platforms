variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(any)
}
variable "instance_name" {
  description = "The name of the instance"
  type        = string
}
variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}
variable "instance_type" {
  description = "The instance type to use for the instance"
  type        = string
}
variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}
variable "security_groups" {
  description = "The security groups to use for the instance"
  type        = list(string)
}
variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}
variable "subnet_id" {
  description = "The subnet ID to use for the instance"
  type        = string
}
variable "user_data" {
  type        = string
  default     = null
  description = "User data script content to run on EC2 (optional)"
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the instance"
  type        = string
  default     = ""
}

variable "create_route53_record" {
  description = "Whether to create a Route53 record for the instance"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "The Route 53 zone ID for DNS records."
  type        = string
}
variable "record_name" {
  description = "The name of the DNS record to create for the instance."
  type        = string 
  default = "" 
}

variable "volume_size" {
  description = "The size of the root EBS volume in GB"
  type        = number
}