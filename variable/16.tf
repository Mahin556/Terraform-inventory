variable "users" {
  type = list(map(string))
  default = [
    {
      name = "mahin"
      role = "admin"
    },
    {
      name = "raza"
      role = "developer"
    }
  ]
}
resource "aws_iam_user" "user" {
  for_each = {
    for user in var.users : user.name => user
  }

  name = each.key
  tags = {
    Role = each.value.role
  }
}
