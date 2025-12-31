
#https://spacelift.io/blog/how-to-use-terraform-variables
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet" {
  type    = string
  default = "subnet1"
}

locals {                         # local variables     #locals block
  ami  = "ami-0d26eb3972b7f8c96" # key value pair
  type = var.instance_type       # refer to variable        
  tags = {                       # scope with in a config/module
    Name = "My Virtual Machine"  # hard-coded value
    Env  = "Dev"
  }
  subnet = "subnet-76a8163a"
  nic    = aws_network_interface.my_nic.id # refer to resource
}