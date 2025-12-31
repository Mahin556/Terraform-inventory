locals {
  name = "eks-vpc"
  vpc_cidr = "10.0.0.0/16"
  azs = ["ap-south-1a","ap-south-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets = ["10.0.3.0/24","10.0.4.0/24"]
  env = "prod"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = local.env
  }
}
