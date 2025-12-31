variable "map_of_objects" {
  description = "This is a variable of type Map of objects"
  type = map(object({
    name = string,
    cidr = string
  }))
  default = {
    "subnet_a" = {
      name = "Subnet A",
      cidr = "10.10.1.0/24"
    },
    "subnet_b" = {
      name = "Subnet B",
      cidr = "10.10.2.0/24"
    },
    "subnet_c" = {
      name = "Subnet C",
      cidr = "10.10.3.0/24"
    }
  }
}