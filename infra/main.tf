# Main infrastructure definition
# Modules will be added here in future phases

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
