#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                              VPC                             #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "vpc" {
  source = "../../modules/network/vpc"

  vpc_cidr_block = var.vpc["vpc_cidr_block"]

  availability_zone = var.vpc["availability_zone"]

  web_subnet_cidr_blocks = var.vpc["web_subnet_cidr_blocks"]
  app_subnet_cidr_blocks = var.vpc["app_subnet_cidr_blocks"]
  db_subnet_cidr_blocks  = var.vpc["db_subnet_cidr_blocks"]

  enable_nat_gateway      = var.vpc["enable_nat_gateway"]
  enable_vpc_flow_logs_cw = var.vpc["enable_vpc_flow_logs_cw"]

  common_tags              = var.common_vars["common_tags"]
  region                   = var.common_vars["aws_region"]
  enable_vpc_endpoints     = var.vpc["enable_vpc_endpoints"]
  vpc_endpoints            = var.vpc["vpc_endpoints"]
  enable_eks_cluster_tags  = var.vpc["enable_eks_cluster_tags"]
  enable_internal_elb_tags = var.vpc["enable_internal_elb_tags"]
  enable_external_elb_tags = var.vpc["enable_external_elb_tags"]
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                           SG and SG Rules                    #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
module "bastion_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["bastion_sg_name"]
  sg_description = var.sg["bastion_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "vpn_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  sg_name        = var.sg["vpn_sg_name"]
  sg_description = var.sg["vpn_sg_description"]
  vpc_id         = module.vpc.vpc_id
}
module "rds_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["rds_sg_name"]
  sg_description = var.sg["rds_sg_description"]
}

module "elastic_cache_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["elastic_cache_sg_name"]
  sg_description = var.sg["elastic_cache_sg_description"]
}
module "backend_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["backend_sg_name"]
  sg_description = var.sg["backend_sg_description"]
}
module "frontend_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["frontend_sg_name"]
  sg_description = var.sg["frontend_sg_description"]
}
module "internal_alb_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["internal_alb_sg_name"]
  sg_description = var.sg["internal_alb_sg_description"]
}
module "external_alb_sg" {
  source         = "../../modules/network/sg"
  common_tags    = var.common_vars["common_tags"]
  vpc_id         = module.vpc.vpc_id
  sg_name        = var.sg["external_alb_sg_name"]
  sg_description = var.sg["external_alb_sg_description"]
}

module "sg_rules" {
  source = "../../modules/network/sg_rules"
  rules  = local.resolved_sg_rules
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                              IAM Roles                       #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "backend_iam_role" {
  source      = "../../modules/iam/iam-ec2"
  common_tags = var.common_vars.common_tags
  role_name   = var.iam_role.backend_role_name

  policy_file = "${path.module}/../env/${var.common_vars.common_tags["Environment"]}/policies/${var.common_vars.common_tags["Environment"]}-backend-policy.json"
}

module "frontend_iam_role" {
  source      = "../../modules/iam/iam-ec2"
  common_tags = var.common_vars.common_tags
  role_name   = var.iam_role.frontend_role_name

  policy_file = "${path.module}/../env/${var.common_vars.common_tags["Environment"]}/policies/${var.common_vars.common_tags["Environment"]}-frontend-policy.json"
}

module "bastion_iam_role" {
  source      = "../../modules/iam/iam-ec2"
  common_tags = var.common_vars.common_tags
  role_name   = var.iam_role.bastion_role_name
  policy_file = "${path.module}/../env/${var.common_vars.common_tags["Environment"]}/policies/${var.common_vars.common_tags["Environment"]}-bastion-policy.json"
}

# module "vpn_iam_role" {
#   source      = "../../modules/iam/iam-ec2"
#   common_tags = var.common_vars.common_tags
#   role_name   = var.iam_role.vpn_role_name
#   policy_file = "${path.module}/../env/${var.common_vars.common_tags["Environment"]}/policies/${var.common_vars.common_tags["Environment"]}-vpn-policy.json"
# }

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                         ACM Certificates                     #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "alb_acm" {
  source            = "../../modules/acm"
  common_tags       = var.common_vars.common_tags
  domain_name       = var.acm["lb_domain_name"]
  validation_method = var.acm["lb_validation_method"]
  zone_id           = var.common_vars["zone_id"]
}

module "cloudfront_acm" {
  source            = "../../modules/acm"
  common_tags       = var.common_vars.common_tags
  domain_name       = var.acm["cloudfront_domain_name"]
  validation_method = var.acm["cloudfront_validation_method"]
  zone_id           = var.common_vars["zone_id"]
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                          RDS[MySQL]                          #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
module "rds" {
  source                 = "../../modules/storage/rds"
  username               = local.rds_username
  password               = local.rds_password
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.rds_sg.sg_id]
  common_tags            = var.common_vars["common_tags"]
  zone_id                = var.common_vars["zone_id"]
  allocated_storage      = var.rds["allocated_storage"]
  engine                 = var.rds["engine"]
  engine_version         = var.rds["engine_version"]
  instance_class         = var.rds["instance_class"]
  publicly_accessible    = var.rds["publicly_accessible"]
  skip_final_snapshot    = var.rds["skip_final_snapshot"]
  storage_type           = var.rds["storage_type"]
  rds_record_name        = var.rds["rds_record_name"]
  record_type            = var.rds["record_type"]
  ttl                    = var.rds["ttl"]
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                    Elastic Cahce[Valkey]                     #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "elasticache" {
  source                  = "../../modules/storage/elastic_cache"
  common_tags             = var.common_vars["common_tags"]
  zone_id                 = var.common_vars["zone_id"]
  security_group_ids      = [module.elastic_cache_sg.sg_id]
  subnet_ids              = module.vpc.db_subnet_ids
  engine                  = var.elastic_cache["engine"]
  major_engine_version    = var.elastic_cache["major_engine_version"]
  elasticache_record_name = var.elastic_cache["elasticache_record_name"]
  record_type             = var.elastic_cache["record_type"]
  ttl                     = var.elastic_cache["ttl"]
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                         EC2[bastion]                         #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "bastion" {
  source      = "../../modules/compute/ec2"
  common_tags = var.common_vars["common_tags"]

  ami             = data.aws_ami.amazon_linux.id
  security_groups = [module.bastion_sg.sg_id]
  subnet_id       = module.vpc.web_subnet_ids[0]

  zone_id       = var.common_vars["zone_id"]
  volume_size   = var.bastion["volume_size"]
  instance_name = var.bastion["instance_name"]
  instance_type = var.bastion["instance_type"]
  monitoring    = var.bastion["monitoring"]
  key_name      = var.bastion["key_name"]

  user_data            = file("${path.module}/../env/${var.common_vars.common_tags["Environment"]}/scripts/bastion.sh")
  iam_instance_profile = module.bastion_iam_role.instance_profile_id
  depends_on           = [module.rds, module.bastion_iam_role]
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                           EC2[VPN]                           #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# module "vpn" {
#   source      = "../../modules/compute/ec2"
#   common_tags = var.common_vars["common_tags"]

#   ami             = data.aws_ami.openvpn.id
#   security_groups = [module.vpn_sg.sg_id]
#   subnet_id       = module.vpc.web_subnet_ids[1]


#   iam_instance_profile = module.vpn_iam_role.instance_profile_id

#   zone_id       = var.common_vars["zone_id"]
#   volume_size   = var.vpn["volume_size"]
#   instance_name = var.vpn["instance_name"]
#   instance_type = var.vpn["instance_type"]
#   monitoring    = var.vpn["monitoring"]
#   key_name      = var.vpn["key_name"]
#   user_data     = file("${path.module}/../env/${var.common_vars.common_tags["Environment"]}/scripts/openvpn.sh")
#   depends_on    = [module.vpc]
# }

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
#                       Internal & External ALB                #
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

module "internal-alb" {
  source                     = "../../modules/network/elb"
  common_tags                = var.common_vars["common_tags"]
  security_groups            = [module.internal_alb_sg.sg_id]
  subnets                    = module.vpc.app_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  lb_name                    = var.internal_alb.lb_name
  enable_deletion_protection = var.internal_alb.enable_deletion_protection
  choose_internal_external   = var.internal_alb.choose_internal_external
  load_balancer_type         = var.internal_alb.load_balancer_type
  enable_zonal_shift         = var.internal_alb.enable_zonal_shift
  tg_port                    = var.internal_alb.tg_port
  health_check_path          = var.internal_alb.health_check_path
  enable_http                = var.internal_alb.enable_http
  enable_https               = var.internal_alb.enable_https
  zone_id                    = var.common_vars["zone_id"]
  record_name                = var.internal_alb.record_name
}



module "external-alb" {
  depends_on                 = [module.alb_acm]
  source                     = "../../modules/network/elb"
  common_tags                = var.common_vars["common_tags"]
  security_groups            = [module.external_alb_sg.sg_id]
  subnets                    = module.vpc.web_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  lb_name                    = var.external_alb.lb_name
  enable_deletion_protection = var.external_alb.enable_deletion_protection
  choose_internal_external   = var.external_alb.choose_internal_external
  load_balancer_type         = var.external_alb.load_balancer_type
  enable_zonal_shift         = var.external_alb.enable_zonal_shift
  tg_port                    = var.external_alb.tg_port
  health_check_path          = var.external_alb.health_check_path
  enable_http                = var.external_alb.enable_http
  enable_https               = var.external_alb.enable_https
  certificate_arn            = module.alb_acm.certificate_arn
  zone_id                    = var.common_vars["zone_id"]
  record_name                = var.external_alb.record_name
}