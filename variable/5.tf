variable "object_type" {
  description = "This is a variable of type object"
  type = object({
    name    = string
    age     = number
    enabled = bool
  })
  default = {
    name    = "John Doe"
    age     = 30
    enabled = true
  }
}
