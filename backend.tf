# Remote state configuration
# IMPORTANT: Create the S3 bucket and DynamoDB table manually before using this backend
# See README.md for instructions

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket" # Change this!
    key            = "eks-monitoring/terraform.tfstate"
    region         = "us-east-1" # Change this to match your region!
    encrypt        = true
    dynamodb_table = "terraform-state-lock"

    # Optional: Enable versioning on your S3 bucket for state history
  }
}

# Note: For initial setup, you can comment out the backend block above
# and use local state, then migrate to S3 backend after bucket creation