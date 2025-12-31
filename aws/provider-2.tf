#Terraform will work without AWS CLI also but AWS CLI make things easy it allow easy way to setup credentials.
#Terraform can use the credentials that configured by AWS CLI.
#Set credentials:
# export AWS_ACCESS_KEY_ID=AKIAxxxx
# export AWS_SECRET_ACCESS_KEY=xxxx
# export AWS_DEFAULT_REGION=ap-south-1

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "terraform-no-cli-demo-12345"
}

# Run:
# terraform init
# terraform apply

# What happens internally:
# - Terraform downloads AWS provider
# - AWS provider uses AWS SDK
# - HTTPS API call → CreateBucket
# - S3 bucket created successfully