#WHEN AWS CLI *IS* REQUIRED (IMPORTANT)
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "aws ec2 describe-instances"
  }
}

# Here:
# - Terraform DOES NOT call AWS CLI
# - YOU are calling AWS CLI
# - CLI must be installed manually

# This is NOT Terraform’s responsibility.