# Instance count with type and validation
variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to launch"
  default     = 2

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}