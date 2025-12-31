# https://spacelift.io/blog/terraform-locals#combine-terraform-local-with-variable
# Terraform variables take input from users (.tfvars, CLI, etc.).
# Locals are internal expressions used to build complex logic.
# Locals cannot be set using user input or .tfvars, and are computed only within the module.
# They are mainly used to manipulate information from another Terraform component, like a variables, expressions, hardcode, a resource or a data source, and you can easily produce more meaningful results.

variable "bucket_prefix" {
  type    = string
  default = "mybucketname"
}

locals {
  bucket_name = "${var.bucket_prefix}-bucket1"
  env_tag     = "dev"
}

resource "aws_s3_bucket" "my_test_bucket" {
  bucket = local.bucket_name
#   acl    = "private"
  tags = {
    Name        = local.bucket_name
    Environment = local.env_tag
  }
}

output "final_bucket_name" {
  value = local.bucket_name
}