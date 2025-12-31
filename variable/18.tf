########################################
# Variable Declarations with Best Practices
########################################

# https://spacelift.io/blog/how-to-use-terraform-variables#terraform-variables-best-practices

# AWS Region with default value and validation
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"

  validation {
    condition     = can(regex("^us-", var.region))
    error_message = "Only 'us-*' AWS regions are allowed."
  }
}

