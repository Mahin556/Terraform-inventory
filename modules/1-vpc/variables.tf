variable "vpc_config" {
  description = "To get the CIDR and name of VPC from the User"
  type = object({
    cidr = string
    name = string
  })
  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr))
    error_message = "Invalid VPC CIDR:- ${var.vpc_config.cidr}"
  }
}

variable "subnet_config" {
  description = "To get the subnet and AZs from the User"
  type = map(object({
    cidr = string
    az = string
    public = optional(bool, false)
  }))
  validation {
    condition = alltrue([ for config in var.subnet_config: can(cidrnetmask(config.cidr)) ])
    error_message = "Invalid Subnet CIDR"
  }
}
