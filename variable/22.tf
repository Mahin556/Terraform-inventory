# Tags with optional object attributes
variable "tags" {
  type = object({
    Name = string
    Env  = optional(string)
  })
  description = "Tags to apply to resources"
  default = {
    Name = "my-resource"
    Env  = "dev"
  }
}
