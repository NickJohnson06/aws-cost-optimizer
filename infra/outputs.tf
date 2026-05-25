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

output "api_gateway_url" {
  description = "The URL of the API Gateway stage"
  value       = aws_api_gateway_stage.api.invoke_url
}

output "api_lambda_function_name" {
  description = "The name of the API Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}


