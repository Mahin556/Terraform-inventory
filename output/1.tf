# Output variables display useful data after terraform apply, such as:
#   EC2 instance IDs
#   Public IPs
#   DNS names
#   Endpoint URLs
#   Module return values

output "instance_id" {
  value       = aws_instance.myvm.id
  description = "AWS EC2 instance ID"
  sensitive   = false
}

# value: The actual value to return
# description: Optional. Helpful comment
# sensitive: Optional. Hides value in output if true



# Access Output Variables
# terraform output
# Sample output: instance_id = "i-08e3e7c0db1234567"
# To get a single output: terraform output instance_id

#  Sensitive Outputs
# sensitive = true
# # my_password = <sensitive>
# output "show_password" {
#   value = nonsensitive(var.secret)
# }
