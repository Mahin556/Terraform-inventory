#EC2 INSTANCE WITH IAM ROLE (NO CREDENTIALS, NO CLI)
#Assume:
# - EC2 instance
# - IAM Role attached (AmazonEC2FullAccess)
# - NO aws cli installed
# - NO ~/.aws/credentials

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0abcdef"
  instance_type = "t2.micro"
}

#What happens:
# - AWS provider queries Instance Metadata Service (IMDS)
# - Retrieves temporary credentials from IAM role
# - Uses AWS API → RunInstances

