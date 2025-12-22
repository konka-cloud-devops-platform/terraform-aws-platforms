common_vars = {
  environment  = "dev"
  project_name = "moneylag-eks"
  aws_region  = "ap-south-1"
  common_tags = {
    Owner       = "devops-team"
  }
}
vpc = {
    vpc_cidr_block            = "10.0.0.0/16"
    availability_zone         = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
    db_subnet_cidr_blocks      = ["10.0.100.0/24", "10.0.110.0/24", "10.0.120.0/24"]
    enable_nat_gateway        = true
    enable_vpc_flow_logs_cw   = true
}