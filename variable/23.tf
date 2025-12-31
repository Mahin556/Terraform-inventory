# Sensitive database password (should be passed via TF_VAR_ or .tfvars file)
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}