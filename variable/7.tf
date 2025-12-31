#Variable name can be anything
variable "instance_type" {
  description = "What type of instance you want?"
  type        = string
  validation {
    condition     = var.instance_type == "t2.micro" || var.instance_type == "t3.micro"
    error_message = "Only 't2.micro' or 't3.micro' is allowed for instance_type."
  }
}
# Without default value it will ask for value on terminal
# we can use condition here
#   1. condition prevent user to input wrong values
#   2. condition restrict used to input only selected values from all the supported values

# variable "v_size" {
#   description = "What size of volume you want?"
#   type        = number
#   default     = 30
# }

# variable "v_type" {
#   description = "What type of volume you want?"
#   type        = string
#   default     = "gp2"
# }