variable "list" {
  type = list(object({
    name = string
    sex  = string
    age  = number
  }))
  default = [{
    name = "mahin"
    sex  = "male"
    age  = 22
    },
    {
      name = "raza"
      sex  = "male"
      age  = 22
      # demo = 1
  }]
}
output "demo" {
  value = var.list
}