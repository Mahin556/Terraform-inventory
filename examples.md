```hcl
terraform {
  required_providers { # To get a specific version of provider plugins
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" { # Get the AWS provider plugin
  region = "us-east-1"  # Set your desired AWS region
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Specify an appropriate AMI ID
  instance_type = "t2.micro"               # Define instance type
}
```

* `ami` ID is immutable if we changed new instance created and old one destroyed(teraform make sure --> delete and then create new instance).
* `instance_type` is mutable we can change it for the instance with out deleting instance. 

---
* users.yaml
```yaml
users:
  - name: john
    roles: [AmazonEC2FullAccess]
  - name: paul
    roles: [AmazonS3FullAccess]
  - name: flik
    roles: [AmazonEC2FullAccess,AmazonS3FullAccess]
```
```hcl
locals {
  users_data = yamldecode(file("./users.yaml")).users

#   user_role_pair = [ for user in local.users_data: [ for role in user.roles: {
#     user = user.name
#     role = role
#   }] ]
    user_role_pair = flatten([ for user in local.users_data: [ for role in user.roles: {
    user = user.name
    role = role
  }] ])
}
```
* main.tf
```hcl
# output "user_info-0" {
#   value = local.user_role_pair
# }

output "user_info-01" {
  value = local.user_role_pair
}

output "user_info" {
  value = local.users_data
}

output "user_info-1" {
  value = local.users_data[0]
}

output "user_info-2" {
  value = local.users_data[*].name
}

output "user_info-3" {
  value = toset(local.users_data[*].name)
}

resource "aws_iam_user" "users" {
  for_each = toset(local.users_data[*].name)
  name     = each.value
  tags = {
    list = each.key
  }
}

output "user-info-4" {
  value = aws_iam_user.users
}

resource "aws_iam_user_login_profile" "profile" {
  for_each = aws_iam_user.users
  user     = each.value.name
  password_length = 10
#   password_reset_required = true
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

# 3. Attach policies to users based on role
resource "aws_iam_user_policy_attachment" "policy_attach" {
  for_each = {
    for pair in local.user_role_pair :
    "${pair.user}-${pair.role}" => pair
  }
  user       = aws_iam_user.users[each.value.user].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.role}"
}
```
* variable.tf
```hcl
variable "region" {
    description = "value of the region"
    type = string
    default = "ap-south-1"
}
```
---
* terraform.tfvars
```hcl
region   = "ap-south-1"
env      = "prod"
env_prod = 20
env_dev  = 10
```
* variable.tf
```hcl
variable "region" {
    description = "value of the region"
    type = string
    default = "ap-south-1"
}
variable "env" {
  type = number
}
variable "env_prod" {
  type = number
}
variable "env_dev" {
  type = number
}
```
* main.tf
```hcl
resource "aws_instance" "myserver" {
  ami           = "ami-0521bc4c70257a054"
  instance_type = "t2.micro"

  tags = {
    Name = "MyServer"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.env == "prod" ? var.env_prod : var.env_dev
  }
}
```
* output.tf
```hcl
output "aws_instance_public_ip" {
  value = aws_instance.myserver.public_ip
  description = "Public IP of the AWS EC2 instance"
}
```