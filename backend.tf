# Remote state configuration
# IMPORTANT: Create the S3 bucket and DynamoDB table manually before using this backend

# Commented out for initial setup - using local state
# Uncomment and configure after creating S3 bucket and testing the infrastructure
#
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"  # Change this!
#     key            = "eks-monitoring/terraform.tfstate"
#     region         = "eu-central-1"  # Match your region
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#     profile        = "default"  # Your AWS CLI profile
#   }
# }

# Note: Currently using local state (terraform.tfstate will be created locally)
# This is fine for initial setup and testing
# 
# To migrate to S3 backend later:
# 1. Create S3 bucket and DynamoDB table
# 2. Uncomment the backend block above and configure it
# 3. Run: terraform init -migrate-state