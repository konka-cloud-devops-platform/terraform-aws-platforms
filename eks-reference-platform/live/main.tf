################################################ VPC MODULE ################################################
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.vpc["project_name"]
  environment  = var.vpc["environment"]

  vpc_cidr_block = vpc.vpc["vpc_cidr_block"]

  availability_zone = var.vpc["availability_zone"]

  public_subnet_cidr_blocks  = var.vpc["public_subnet_cidr_blocks"]
  private_subnet_cidr_blocks = var.vpc["private_subnet_cidr_blocks"]
  db_subnet_cidr_blocks      = var.vpc["db_subnet_cidr_blocks"]

  enable_nat_gateway       = var.vpc["enable_nat_gateway"]
  enable_vpc_flow_logs_cw  = var.vpc["enable_vpc_flow_logs_cw"]

  common_tags = var.vpc["common_tags"]
}