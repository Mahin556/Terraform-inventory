locals {
  resource_tags = {
    project_name = "mytest",
    category     = "devresource"
  }
}
resource "aws_iam_role" "myrole" {
  name = "my_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
  tags = local.resource_tags
}