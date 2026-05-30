# Remote state backend (S3 + DynamoDB locking)
#
# HOW TO ENABLE:
# 1. First run `terraform init` and `terraform apply` WITHOUT this backend block
#    to create the S3 bucket and DynamoDB table that will store state.
# 2. Then uncomment the block below, update bucket/table names to match your
#    actual resource names, and run `terraform init -migrate-state` to move
#    local state into the remote backend.
#
# terraform {
#   backend "s3" {
#     bucket         = "portfolio-site-production-tfstate"
#     key            = "portfolio-site/production/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "portfolio-site-production-tfstate-lock"
#   }
# }
