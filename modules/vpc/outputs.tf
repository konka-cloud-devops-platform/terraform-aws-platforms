output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "web_subnet_ids" {
  description = "List of web subnet IDs"
  value       = aws_subnet.web_subnets[*].id
}

output "app_subnet_ids" {
  description = "List of app subnet IDs"
  value       = aws_subnet.app_subnets[*].id
}

output "db_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.db_subnets[*].id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.default.name
}
