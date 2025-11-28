* Backend config
* Managing a `terraform.tfstate` file in the s3 or other remote storage service.
* Increase Collaboration.
```json
terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.2.0"
    }
  }
  backend "s3" { #backend block for remote state management
    bucket = "mahin-bucket-1cb92966a8b31355b1a8bd48"
    key = "backend.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myserver" {
  ami="ami-0521bc4c70257a054"
  instance_type = "t2.micro"
  tags  = {
    Name = "myserver"
    ENV = "dev"
  }
}
```
```bash
aws s3 ls
```

```bash
aws s3api create-bucket --bucket my-terraform-state-bucket --region us-east-1 #Create S3 Bucket (for Terraform state)

aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1


aws s3api put-bucket-versioning --bucket mahin-terraform-state-bucket --versioning-configuration Status=Enabled #Add versioning (to recover old state versions if needed)

aws dynamodb create-table \
    --table-name terraform-lock-table \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
#Create DynamoDB Table (for state locking)
#This prevents two users from running terraform apply at the same time
```
```json
terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.2.0"
    }
  }
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```