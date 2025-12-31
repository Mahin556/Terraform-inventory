# https://spacelift.io/blog/how-to-use-terraform-variables#variable-precedence
# Terraform Variable Precedence (Highest to Lowest)
# CLI -var option
# CLI -var-file option (.tfvars)
# Environment Variables
# Default Values in variable block
# Interactive Prompt (fallback)

# Secure Variables
#   Avoid putting passwords, API keys, secrets in .tf or .tfvars files. Instead: Use environment variables:
#   export TF_VAR_db_password="supersecret123"
# Or use external secret stores like:
#   AWS Secrets Manager
#   HashiCorp Vault
#   Azure Key Vault