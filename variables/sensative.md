```hcl
# Terraform allows marking variables as *sensitive*.
# This hides their values during:
#   - terraform plan
#   - terraform apply
#   - terminal output printing
#
# BUT NOTE:
#   Sensitive values are STILL stored in the Terraform STATE file.
#   (state is not encrypted unless stored securely!)
# -------------------------------------------------------------------

# --------------------------- EXAMPLE --------------------------------

variable "my_super_secret_password" {
  type      = string
  default   = "super-secret"
  sensitive = true   # <-- hides this value during plan/apply
}

# If you output a sensitive variable WITHOUT marking the output
# as sensitive → Terraform gives an error.

output "my_super_secret_password" {
  value = var.my_super_secret_password
}

# Running "terraform apply" now results in:
#
# ERROR: Output refers to sensitive values
#
# Terraform requires you to explicitly mark outputs as sensitive
# so secrets are not leaked unintentionally.

# ---------------------- FIXING THE ERROR -----------------------------

output "my_super_secret_password" {
  value     = var.my_super_secret_password
  sensitive = true     # <-- REQUIRED so Terraform knows you intend to output a secret
}

# Running terraform apply now prints:
#   my_super_secret_password = (sensitive value)
#
# Terraform hides the actual value for safety.


# -------------------------------------------------------------------
# SHOWING SENSITIVE VALUE IN OUTPUT (UNSAFE BUT POSSIBLE)
# -------------------------------------------------------------------
# If you REALLY want to display a sensitive var,
# Terraform provides the nonsensitive() function.
# This removes the sensitive flag.

variable "my_super_secret_password" {
  type      = string
  default   = "super-secret"
  sensitive = true
}

# Using nonsensitive() → Terraform will show the value

output "my_super_secret_password" {
  value = nonsensitive(var.my_super_secret_password)
}

# Output:
#   my_super_secret_password = "super-secret"
#
# WARNING:
#   This exposes the secret in your terminal output.
#   Only use nonsensitive() when absolutely necessary.


# -------------------------------------------------------------------
# SUMMARY (EASY TO REMEMBER)
# -------------------------------------------------------------------
# 1️⃣ sensitive = true (on variables)
#     → hides value during plan/apply
#
# 2️⃣ sensitive outputs must also mark sensitive = true
#     → otherwise Terraform errors
#
# 3️⃣ nonsensitive() removes the sensitive flag
#     → prints the actual secret (but risky)
#
# 4️⃣ Sensitive values STILL appear in terraform.tfstate
#     → always secure your backend (S3 + KMS / Terraform Cloud / Vault)
```