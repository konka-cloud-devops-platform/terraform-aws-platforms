variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "web_subnet_cidr_blocks" {
  description = "CIDR block for the web subnets"
  type        = list(string)
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = list(string)
}

variable "app_subnet_cidr_blocks" {
  description = "CIDR block for the app subnets"
  type        = list(string)
}

variable "db_subnet_cidr_blocks" {
  description = "CIDR block for the DB subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}
variable "enable_vpc_flow_logs_cw" {
  description = "Enable VPC Flow Logs"
  type        = bool
}
variable "region" {
  description = "Region for Gateway Endpoint"
  type = string
  default = ""
}

variable "enable_vpc_endpoints" {
  description = "Enable or disable all VPC endpoints"
  type        = bool
  default     = false
}

variable "vpc_endpoints" {
  description = "VPC endpoint definitions"
  type = map(object({
    service = string
    type    = string   # Gateway | Interface
    enabled = bool
  }))
  default = {}

  # validation {
  #   condition = alltrue([
  #     for k, v in var.vpc_endpoints :
  #     contains(["Gateway", "Interface"], v.type)
  #   ])
  #   error_message = "VPC endpoint type must be either 'Gateway' or 'Interface'."
  # }
}
  
variable "interface_endpoint_sg_id" {
  description = "Interface endpoint sg id"
  type = string 
}

variable "enable_eks" {
  type    = bool
  default = false
}

variable "enable_internal_elb" {
  type    = bool
  default = false
}

variable "enable_external_elb" {
  type    = bool
  default = false
}