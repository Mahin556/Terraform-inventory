# Number list
variable "numbers1" {
  type    = list(number)
  default = [1, 2, 3, 4, 5]
}

# string list(default)
variable "numbers2" {
  type    = list(string)
  default = ["one", "two", "three"]
}

# Object list of persion
variable "persion" {
  type = list(object({
    fname = string
    lname = string
  }))
  default = [{
    fname = "mahin"
    lname = "raza"
    }, {
    fname = "raza"
    lname = "mahin"
  }]
}

variable "map_list1" {
  type = map(number)
  default = {
    "one"   = 1
    "two"   = 2
    "three" = 3
  }
}

variable "map_list2" {
  type = map(string)
  default = {
    "one"   = "username"
    "two"   = "fname"
    "three" = "lname"
  }
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "instance" {
  type = object({
    instance_type = string
    ami_id        = string
    subnet_id     = string
  })
  default = {
    instance_type = "t2.micro"
    ami_id        = "ami-12345678"
    subnet_id     = "subnet-12345678"
  }
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "ExampleInstance"
    Environment = "Production"
    Owner       = "John Doe"
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b", "us-west-1c"]
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "region" {
  type    = string
  default = "us-west-1"
}