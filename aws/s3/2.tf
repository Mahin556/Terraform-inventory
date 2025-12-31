#Always access a local value using the local. prefix:
# value = local.prefix_elements

locals {
  bucket_name = "my-test-bucket"
  env         = "dev"
}


resource "aws_s3_bucket" "my_test_bucket" {
  bucket = local.bucket_name
#   acl    = "private"
  tags = {
    Name        = local.bucket_name
    Environment = local.env
  }
}


resource "aws_s3_bucket" "my_test_bucket" {
  bucket = "${local.bucket_name}-newbucket"
#   acl    = "private"
  tags = {
    Name        = "${local.bucket_name}-newbucket"
    Environment = local.env
  }
}
