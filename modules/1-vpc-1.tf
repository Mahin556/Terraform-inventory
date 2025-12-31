provider "aws" {
  region = "ap-south-1"
}

module "demo" {
  source = "./1-vpc"
  vpc_config = {
    cidr = "10.0.0.0/16"
    name = "demo-vpc"
  }

  subnet_config = {
    subnet1 = {
      cidr   = "10.0.0.0/24"
      az     = "ap-south-1a"
      public = true
    }
    subnet2 = {
      cidr   = "10.0.1.0/24"
      az     = "ap-south-1b"
      public = false
    }
    subnet3 = {
      cidr   = "10.0.2.0/24"
      az     = "ap-south-1a"
      public = true
    }
    subnet4 = {
      cidr = "10.0.3.0/24"
      az   = "ap-south-1b"
    }
  }
}

output "demo" {
  value = module.demo.vpc_id
}
output "demo1" {
  value = module.demo.public_subnets_id
}
output "demo2" {
  value = module.demo.private_subnets_id
}
