variable "tuple_type" {
  description = "This is a variable of type tuple"
  type        = tuple([string, number, bool])
  default     = ["item1", 42, true]
}

variable "set_example" {
  description = "This is a variable of type set"
  type        = set(string)
  default     = ["item1", "item2", "item3"]
}