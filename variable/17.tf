# Sensitive variables
variable "my_super_secret_password" {
  type      = string
  default   = "super-secret"
  sensitive = true
}
# Output: 
# my_super_secret_password = <sensitive>


# This hides the value from:
#   terraform plan
#   terraform apply
#   terraform output
# But the value is still stored in the state file in plain text (so secure your .tfstate file!).
# Use sensitive = true for all secrets.
# Never commit terraform.tfstate to version control unless encrypted.
# Prefer secret management tools (Vault, AWS Secrets Manager) for real-world production.

# Output Error Without Explicit Sensitivity
# If you try:
output "my_super_secret_password" {
  value = var.my_super_secret_password
}
# You’ll get:
# Error: Output refers to sensitive values


# See the Value Anyway (Optional – Not Recommended for Secrets)
output "my_super_secret_password" {
  value = nonsensitive(var.my_super_secret_password)
}
# Output:
# my_super_secret_password = "super-secret"
# Use nonsensitive() only for debugging or internal use. Avoid using it in shared environments or CI/CD logs.

