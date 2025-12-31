provider "aws" {
  region = "ap-south-1"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name    = "my-vpc"
  cidr    = "10.0.0.0/16"

  azs             = data.aws_availability_zones.azs.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.0.2"
  ami = "ami-0d03cb826412c6b0f"
  name = "single-instance"

  instance_type = "t2.micro"
  monitoring    = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id     = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
