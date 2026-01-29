```hcl
# Before Terraform introduced "variable validation",
# people used a hacky trick: force Terraform to fail
# by calling the file() function with a fake path.
# If the condition is invalid → Terraform throws an error.
#
# -------------------- OLD HACKY VALIDATION --------------------------
locals {
  vpc_cidr = "10.0.0.0/16"

  # BAD PRACTICE (old method)
  # If mask <16 or >30 → try to read a non-existent file → Terraform fails
  vpc_cidr_validation = split("/", local.vpc_cidr)[1] < 16 ||
                        split("/", local.vpc_cidr)[1] > 30
                        ? file(format("\nERROR: VPC CIDR %s must be /16 to /30", local.vpc_cidr))
                        : null
}

# Result:
# - If CIDR is valid  → Terraform applies normally
# - If CIDR is invalid → Error comes from file() → confusing message


# -------------------------------------------------------------------
# TERRAFORM VARIABLE VALIDATION (MODERN, CLEAN, RECOMMENDED)
# -------------------------------------------------------------------
# Terraform now supports proper validation inside variable blocks.
# This gives clean errors, clear messages, and avoids hacks.

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/8"

  validation {
    # CONDITION:
    # CIDR suffix must be >16 AND <30
    condition = split("/", var.cidr_block)[1] > 16 &&
                split("/", var.cidr_block)[1] < 30

    # CUSTOM ERROR MESSAGE:
    error_message = "Your VPC CIDR mask must be between /16 and /30."
  }
}

# If cidr_block = "10.0.0.0/8"
# → Terraform fails with clean error:
#     "Your VPC CIDR mask must be between /16 and /30."


# -------------------------------------------------------------------
# ADVANCED VALIDATION: CHECK CIDR FORMAT
# -------------------------------------------------------------------
# We can validate the structure of the string itself.

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    # CONDITION:
    # - Must contain "/"
    # - Must have exactly 4 octets (length of split(".") == 4)
    condition = strcontains(var.cidr_block, "/") &&
                length(split(split(var.cidr_block,"/"), ".")) == 4

    # ERROR IF FAILS:
    error_message = "Your VPC CIDR does not follow correct CIDR format."
  }
}

# -------------------------------------------------------------------
# SUMMARY (EASY TO REMEMBER)
# -------------------------------------------------------------------
# OLD WAY (BAD):
#   - Use file() with fake path to force an error.
#   - Confusing and ugly errors.
#
# NEW WAY (GOOD):
#   - validation { condition + error_message }
#   - Clean, readable, accurate errors.
#   - Helps catch mistakes before apply.
```
```hcl
variable "ami" {
 type        = string
 description = "AMI ID for the EC2 instance"
 default     = "ami-0d26eb3972b7f8c96"
 
 validation {
   condition     = length(var.ami) > 4 && substr(var.ami, 0, 4) == "ami-"
   error_message = "Please provide a valid value for variable AMI."
 }
}
```