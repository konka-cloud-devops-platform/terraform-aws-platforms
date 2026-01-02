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

output "bastion" {
  description = "Bastion Sg ID"
  value       = module.bastion.sg_id
}


output "vpn" {
  description = "VPN Sg ID"
  value       = module.vpn.sg_id
}

output "elasticache" {
  description = "ElastiCache Sg ID"
  value       = module.elasticache.sg_id
}

output "rds" {
  description = "RDS Sg ID"
  value       = module.rds.sg_id
}

output "controlplane" {
  description = "Controlplane Sg ID"
  value       = module.controlplane.sg_id
}

output "nodegroup" {
  description = "Nodegroup Sg ID"
  value       = module.nodegroup.sg_id
}

output "external_alb" {
  description = "External ALB Sg ID"
  value       = module.external_alb.sg_id
}

output "interface_endpoint_sg" {
  description = "Interface Endpoint Sg ID"
  value       = module.interface_endpoint_sg.sg_id
}