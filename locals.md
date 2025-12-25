### References:-
- https://spacelift.io/blog/terraform-locals#using-for-loop-in-a-local

---

* WHAT ARE TERRAFORM LOCALS?
```hcl
# • Locals are named values defined inside a module.
# • They help eliminate duplication in your code.
# • They improve readability by assigning a meaningful name to expressions.
# • Very similar to “local variables” inside a function in traditional languages.

# Example:
locals {
  bucket_name = "${var.text1}-${var.text2}"
}

# You can now use:
  local.bucket_name
# anywhere inside the same module.
```

* WHY USE LOCALS?
```hcl
# ✔ To avoid repeating long expressions
# ✔ To simplify complex values before using them
# ✔ To group computation results with meaningful names
# ✔ To increase readability and maintainability
#
# Locals are computed once and then reused throughout the module.
```

* LOCALS VS VARIABLES
```hcl
# 1) Scope Difference
# --------------------
# • Locals → scoped ONLY within the module where they are defined.
# • Variables → can be:
#     - module-scoped
#     - passed from parent module
#     - overridden through CLI, tfvars, environment vars, etc.

# Local = private to module  
# Variable = can be public input

# 2) Mutability
# -------------
# • A local CANNOT change its value once assigned.
# • A variable CAN take dynamic values (via CLI, tfvars, default values).
#
# Locals are meant for fixed computed values, not user inputs.

# 3) Usage Style
# --------------
# • Variables → external input
# • Locals → computed values from variables/resources

# Variables provide input:
   var.project_name
#
# Locals transform input into something reusable:
   local.full_name = "${var.project_name}-prod"
```

* WHEN SHOULD YOU USE LOCALS?
```hcl
# • When combining two or more variable values  
# • When you have repeated values across resources  
# • When your expressions become long or unreadable  
# • When you want consistent naming across modules  
# • Locals CANNOT accept external input
# • Locals CANNOT be set in .tfvars
# • Locals are computed from other Terraform elements
# • They are perfect for manipulating or enhancing data from:
#   • input variables
#   • resources
#   • data sources
#   • functions
# • Cannot pass value to a local from CLI or tfvars
# • Locals are computed once per run and are read-only
#
# Best practice:
#   • Put locals into a `locals.tf` file
#   • You can have multiple `locals` blocks, but NOT duplicate names

# Example:
locals {
  tags = {
    Environment = var.env
    Owner       = var.owner
    Project     = "${var.project}-${var.env}"
  }
}

# Use in resources:
   tags = local.tags
```

```hcl
locals {
  bucket_name = "mytest"
  env         = "dev"
  instance_ids = concat(aws_instance.ec1.*.id, aws_instance.ec3.*.id)
  env_tags = {
    envname = "dev"
    envteam = "devteam"
  }
  prefix_elements = [for elem in ["a", "b", "c"] : format("Hello %s", elem)]
  even_numbers = [for i in [1, 2, 3, 4, 5, 6] : i if i % 2 == 0]
}

resource "aws_s3_bucket" "my_test_bucket" {
  bucket = local.bucket_name
  acl    = "private"
 
  tags = {
    Name        = local.bucket_name
    Environment = local.env
  }
}

resource "aws_s3_bucket" "my_test_bucket" {
  bucket = "${local.bucket_name}-newbucket"
  acl    = "private"
 
  tags = {
    Name        = local.bucket_name
    Environment = local.env
  }
}
```
```hcl
# ──────────────────────────────────────────────────────────────────────────────
# EXAMPLE 1 — Combine Variable with Local
# ──────────────────────────────────────────────────────────────────────────────

# variables.tf
variable "bucket_prefix" {
  type    = string
  default = "mybucketname"
}

# locals.tf
locals {
  bucket_name = "${var.bucket_prefix}-bucket1"
}

# main.tf
resource "aws_s3_bucket" "my_test_bucket" {
  bucket = local.bucket_name
  acl    = "private"
}
```
```hcl
# ──────────────────────────────────────────────────────────────────────────────
# EXAMPLE 2 — Using locals for default tag values
# ──────────────────────────────────────────────────────────────────────────────

locals {
  resource_tags = {
    project_name = "mytest"
    category     = "devresource"
  }
}

resource "aws_iam_role" "myrole" {
  name = "my_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })

  tags = local.resource_tags
}
```
```hcl
# ──────────────────────────────────────────────────────────────────────────────
# EXAMPLE 3 — Merge Variables and Locals Together
# ──────────────────────────────────────────────────────────────────────────────

variable "res_tags" {
  type = map(string)
  default = {
    dept = "finance"
    type = "app"
  }
}

locals {
  all_tags = {
    env       = "dev"
    terraform = true
  }

  # Merge variable tags + local tags
  applied_tags = merge(var.res_tags, local.all_tags)
}

resource "aws_s3_bucket" "tagsbucket" {
  bucket = "tags-bucket"
  acl    = "private"

  tags = local.applied_tags
}

output "out_tags" {
  value = local.applied_tags
}
```