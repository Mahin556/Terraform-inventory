# Instance type with allowed values
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3a.micro"], var.instance_type)
    error_message = "Allowed instance types are: t2.micro, t3.micro, t3a.micro"
  }
}
