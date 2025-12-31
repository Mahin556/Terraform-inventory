terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  users_data = yamldecode(file("./users.yaml")).users
  user_role_mapping = flatten([for obj in local.users_data : [for role in obj.roles : {
    user_name = obj.name
    role_name = role
  }]])
}

output "demo" {
  value = local.users_data
}

output "demo1" {
  value = local.user_role_mapping
}

output "demo2" {
  value = flatten(local.user_role_mapping)
}

resource "aws_iam_user" "users" {
  for_each = toset(local.users_data[*].name)
  name     = each.value
  tags = {
    Name = each.value
  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each        = toset(local.users_data[*].name)
  user            = each.value
  password_length = 10
  depends_on = [ aws_iam_user.users ]
}

resource "aws_iam_user_policy_attachment" "users" {
  for_each = {
    for obj in local.user_role_mapping : obj.user_name => obj
  }
  user       = each.key
  policy_arn = "arn:aws:iam::aws:policy/${each.value.role_name}"
}
