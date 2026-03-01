variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
# Launch Template Variables
variable "instance_name" {
  description = "Instance name for tagging resources"
  type        = string
}
variable "instance_profile" {
  description = "ARN of the IAM instance profile to attach to the launch template"
  type        = string
  
}
variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
}
variable "image_id" {
  description = "AMI ID to use for the launch template"
  type        = string
}
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}
variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
}
variable "security_groups" {
  description = "List of security group IDs to associate with the launch template"
  type        = list(string)
  default     = []
}

# ASG variables
variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
}
variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
}
variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
}
variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}
variable "target_group_arns" {
  description = "List of target group ARNs for the ASG"
  type        = list(string)
  default     = []
}
variable "target_value" {
  description = "Target value for the ASG's scaling policy"
  type        = number
}

variable "monitoring_enable" {
  description = "Enable detailed monitoring for the instances"
  type        = bool
}