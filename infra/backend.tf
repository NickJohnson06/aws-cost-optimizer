terraform {
  backend "s3" {
    bucket         = "aws-cost-optimizer-state-20251214065602040100000001"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-cost-optimizer-locks"
    encrypt        = true
  }
}
