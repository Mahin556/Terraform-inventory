locals {
  add = 2 + 2
  sub = 2 - 2
  mul = 2 * 2
  div = 2 / 2
  mod = 2 % 2
  eq  = 2 != 3
}

output "name1" {
  value = local.add
}

output "name2" {
  value = local.mod
}

output "name3" {
  value = local.eq
}
