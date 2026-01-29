```hcl
# When Terraform finishes creating infrastructure,
# we often need important info such as:
#   - EC2 instance IDs
#   - Public/Private IPs
#   - Load Balancer DNS names
#   - Database endpoints
#   - Credentials, etc.
#
# Instead of searching inside the Terraform state file,
# output variables print these values in the console.
#
# They also allow CHILD modules to pass values up
# to the ROOT module.

output "instance_id" {
  value       = aws_instance.myvm.id      # Reference EC2 instance ID
  description = "AWS EC2 instance ID"     # Optional description
  sensitive   = false                     # If true, hides value in output
}

# After terraform apply:
#   terraform output
#   instance_id = "i-xxxxxxxx"

```