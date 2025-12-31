#https://spacelift.io/blog/how-to-use-terraform-variables
variable "string_type" {
  description = "This is a variable of type string"
  type        = string
  default     = "Default string value for this variable"
}