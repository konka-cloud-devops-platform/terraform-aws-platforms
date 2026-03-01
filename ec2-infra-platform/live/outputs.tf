# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "web_subnet_ids" {
  description = "List of web subnet IDs"
  value       = module.vpc.web_subnet_ids
}

output "app_subnet_ids" {
  description = "list of app subnet IDs"
  value       = module.vpc.app_subnet_ids
}

output "db_subnet_ids" {
  description = "List of DB subnet IDs"
  value       = module.vpc.db_subnet_ids
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.vpc.db_subnet_group_name
}
# Security Groups IDs
output "bastion_sg_id" {
  description = "Bastion Security Group ID"
  value       = module.bastion_sg.sg_id
}
output "vpn_sg_id" {
  description = "VPN Security Group ID"
  value       = module.vpn_sg.sg_id
}
output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = module.rds_sg.sg_id
}
output "elastic_cache_sg_id" {
  description = "Elasticache Security Group ID"
  value       = module.elastic_cache_sg.sg_id
}
output "backend_sg_id" {
  description = "Backend Security Group ID"
  value       = module.backend_sg.sg_id
}
output "frontend_sg_id" {
  description = "Frontend Security Group ID"
  value       = module.frontend_sg.sg_id
}
output "internal_alb_sg_id" {
  description = "Internal ALB Security Group ID"
  value       = module.internal_alb_sg.sg_id
}
output "external_alb_sg_id" {
  description = "External ALB Security Group ID"
  value       = module.external_alb_sg.sg_id
}

output "backend_instance_profile_id" {
  description = "Backend IAM profile ID"
  value       = module.backend_iam_role.instance_profile_id
}

output "frontend_instance_profile_id" {
  description = "Frontend IAM profile ID"
  value       = module.frontend_iam_role.instance_profile_id
}

output "bastion_instance_profile_id" {
  description = "Bastion IAM profile ID"
  value       = module.bastion_iam_role.instance_profile_id
}
# output "vpn_instance_profile_id" {
#   description = "VPN IAM profile ID"
#   value       = module.vpn_iam_role.instance_profile_id
# }
output "lb_acm_arn" {
  value = module.alb_acm.certificate_arn
}

output "cf_acm_arn" {
  value = module.cloudfront_acm.certificate_arn
}

output "db_endpoint" {
  value = module.rds.endpoint
}
output "elsticache_endpoint" {
  value = module.elasticache.endpoint
}
