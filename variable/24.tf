# Map of subnets with nested objects (for_each example)
variable "my_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "Subnets for My VPC"
  default = {
    "subnet-a" = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    "subnet-b" = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }
}