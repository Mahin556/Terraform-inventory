* Terraform deal with multiple data types like string, maps, sets, list etc
* `for_each` allow to iterate through each item in map and sets.

```hcl
locals {
  instances = {
    "1" = {
      ami            = "ami-2345rtfv23f"
      subnet_id      = "subnet-234r5t"
      instance_type  = "t3a.medium"
      volume_size    = 10
      volume_type    = "gp3"
      environment    = "dev"
    },
    "2" = {
      ami            = "ami-2345rtfv23f"
      subnet_id      = "subnet-234r5t"
      instance_type  = "t3a.medium"
      volume_size    = 10
      volume_type    = "gp3"
      environment    = "dev"
    }
  }
}

resource "aws_instance" "ec2" {
  for_each            = local.instances

  ami                 = each.value.ami
  subnet_id           = each.value.subnet_id
  instance_type       = each.value.instance_type

  root_block_device {
    volume_size       = each.value.volume_size
    volume_type       = each.value.volume_type
  }

  tags = {
    Name = "Instance-${each.key}"
    Env  = each.value.environment
  }
}
```

```hcl
variable "instances" {
  type = map(objects({
    ami = string
    subnet_id = string
    instance_type = string
    volume_size = number
    volume_type = string
    environment = string
  }))
  default = {
    "1" = {
      ami            = "ami-2345rtfv23f"
      subnet_id      = "subnet-234r5t"
      instance_type  = "t3a.medium"
      volume_size    = 10
      volume_type    = "gp3"
      environment    = "dev"
    },
    "2" = {
      ami            = "ami-2345rtfv23f"
      subnet_id      = "subnet-234r5t"
      instance_type  = "t3a.medium"
      volume_size    = 10
      volume_type    = "gp3"
      environment    = "dev"
    }
  }
}

resource "aws_instance" "ec2" {
  for_each            = var.instances

  ami                 = each.value.ami
  subnet_id           = each.value.subnet_id
  instance_type       = each.value.instance_type

  root_block_device {
    volume_size       = each.value.volume_size
    volume_type       = each.value.volume_type
  }

  tags = {
    Name = "Instance-${each.key}"
    Env  = each.value.environment
  }
}
```
```hcl
# https://spacelift.io/blog/how-to-use-terraform-variables#using-variables-in-foreach-loop
# You want to create multiple AWS subnets in different Availability Zones (AZs) with unique CIDR blocks — dynamically and cleanly.


#Define a Complex Variable
variable "my_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "Subnets for My VPC"
}


#Set Variable in .tfvars
# my_subnets = {
#   "a" = { cidr = "10.0.1.0/26", az = "eu-central-1a" },
#   "b" = { cidr = "10.0.2.0/26", az = "eu-central-1a" },
#   "c" = { cidr = "10.0.3.0/26", az = "eu-central-1b" },
#   "d" = { cidr = "10.0.4.0/26", az = "eu-central-1c" },
#   "e" = { cidr = "10.0.5.0/26", az = "eu-central-1b" }
# }

# Name the file terraform.tfvars or pass it with -var-file=values.tfvars.

# Use for_each in Subnet Resource
resource "aws_subnet" "my_subnets" {
  for_each          = var.my_subnets
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "Subnet - ${each.key}"
  }
}
```
