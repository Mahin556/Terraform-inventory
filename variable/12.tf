variable "object" {
  type = object({
    name = string
    sex  = string
    age  = number
  })
  default = {
    name = "mahin"
    sex  = "male"
    age  = 22
    demo = 1 # not print/used(ignored)
  }
}
output "demo" {
  value = var.object
}
