provider "aws" {
  region = "ap-south-1"
}

module "mahin-test-vpc" {
  source  = "Mahin556/mahin-test-vpc/aws"
  version = "1.0.0"
  # insert the 2 required variables here
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "my-vpc"
  }
  Subnet_config = {
    public_subnet-1 = {
        cidr_block = "10.0.1.0/24"
        az = "ap-south-1a"
        #To set the subnet as public default is false
        public = true
    }

    public_subnet-2 = {
        cidr_block = "10.0.3.0/24"
        az = "ap-south-1b"
        public = true
    }

    private_subnet = {
        cidr_block = "10.0.2.0/24"
        az = "ap-south-1a"
    }
  }
}
