```hcl
variable "list" {
  type = list
  default = ["mahin","raza"]
}

output "demo" {
  value = "Name- ${join(" ",var.list)}"
}
```