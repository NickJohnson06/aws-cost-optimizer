output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing the RDS master user password"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}
