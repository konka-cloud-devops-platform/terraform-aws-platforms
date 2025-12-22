variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "vpc" {
  description = "VPC configuration"
  type = object({
    project_name             = string
    environment              = string
    vpc_cidr_block           = string
    availability_zone        = list(string)
    public_subnet_cidr_blocks  = list(string)
    private_subnet_cidr_blocks = list(string)
    db_subnet_cidr_blocks      = list(string)
    enable_nat_gateway       = bool
    enable_vpc_flow_logs_cw  = bool
    common_tags              = map(string)
  })
}
