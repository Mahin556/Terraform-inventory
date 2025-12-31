locals {
  # Arithmetic Operators
  a = 5 + 1
  b = 5 - 1
  c = 5 * 1
  d = 5 / 1
  e = 5 % 1
  f = pow(3, 2) # power as function

  #comparision operator
  g = 5 == 2
  h = 5 != 2
  i = 5 > 2
  j = 5 < 2
  k = 5 >= 2
  l = 5 <= 2

  m = true
  n = false

  o = local.m || local.n # true
  p = local.m && local.n # false
  q = !local.o           # false (because m is true)


  #  Other Operators:
  #   =>: Used in maps to define key-value pairs.
  #   * (Splat operator): Used to extract values from lists or maps.
  #   ${}: Used for string interpolation, embedding expressions within strings
}

output "name" {
  value = "a=${local.a}\nb=${local.b}\nc=${local.c}\nd=${local.d}\ne=${local.e}\n"
}

output "m" {
  value = local.m
}

output "n" {
  value = local.n
}

output "o" {
  value = local.o
}
