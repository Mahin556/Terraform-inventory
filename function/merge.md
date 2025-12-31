```hcl
variable "res_tags" {
  type = map(string)
  default = {
    dept = "finance",
    type = "app"
  }
}

locals {
  all_tags = {
    env       = "dev",
    terraform = true
  }
  applied_tags = merge(var.res_tags, local.all_tags)
}

resource "aws_s3_bucket" "tagsbucket" {
  bucket = "tags-bucket"
# acl    = "private"
  tags = local.applied_tags
}

output "out_tags" {
  value = local.applied_tags
}
```