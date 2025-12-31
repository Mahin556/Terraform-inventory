variable "list" {
  type = list(map(string))
  default = [{
    name = "mahin",
    age  = 22,
    sex  = "male"
    },
    {
      name = "mahin",
      age  = 22,
      sex  = "male",
      demo = 1
  }]
}
output "list" {
  value = var.list
}