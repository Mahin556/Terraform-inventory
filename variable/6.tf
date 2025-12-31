variable "number_type" {
  description = "This is a variable of type number"
  type        = number
  default     = 42
}

variable "boolean_type" {
  description = "This is a variable of type bool"
  type        = bool
  default     = true
}

variable "list_type" {
  description = "This is a variable of type list"
  type        = list(string)
  default     = ["string1", "string2", "string3"]
}

variable "map_type" {
  description = "This is a variable of type map"
  type        = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}