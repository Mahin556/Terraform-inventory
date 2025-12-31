variable "map" {
  type = map(string)
  default = {
    name  = "mahin"
    sex   = "male"
    age   = 22
    demo  = 1 # not have proper format
    demo1 = "num"
  }
}
output "demo" {
  value = var.map
}