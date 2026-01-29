```bash
If none provided → Terraform asks in interactive mode.
CLI -var and -var-file  (HIGHEST PRIORITY)
*.auto.tfvars or *.auto.tfvars.json
terraform.tfvars or terraform.tfvars.json
Environment variables (TF_VAR_name)
5Variable "default" value in .tf file (LOWEST)
```
```hcl
# 1) DEFAULT VALUES
# Terraform uses it unless overridden.
variable "ami" { default = "ami-default" }

# 2) OVERRIDING VARIABLES USING CLI:  -var/-var-file
# You can override any variable using -var arguments.
# Must repeat -var for every variable.
# Example:
terraform plan \
  -var "ami=test" \
  -var "type=t2.nano" \
  -var "tags={\"name\":\"MyVM\",\"env\":\"Dev\"}"

# 3) USING .tfvars FILE
# Better approach when many variables exist.
# Example values.tfvars:
ami  = "ami-0d26eb3972b7f8c96"
type = "t2.nano"
tags = {
  name = "My Virtual Machine"
  env  = "Dev"
}
# Use with:
# terraform plan -var-file="values.tfvars"

# 4) AUTO-LOADING .auto.tfvars
# If file ends with *.auto.tfvars, Terraform loads it automatically.
# Example: values.auto.tfvars
# No need to pass -var-file manually.

# 5) ENVIRONMENT VARIABLES:  TF_VAR_<variable_name>
# Another method to set Terraform variables.
# Export example:
  export TF_VAR_ami=ami-0d26eb3972b7f8c96
# Terraform automatically maps:
  TF_VAR_ami  → variable "ami"
# NOTE: Good for secrets (API keys, passwords).
# Avoid storing sensitive data inside .tfvars.

# 6) OTHER TERRAFORM ENV VARIABLES
TF_LOG       → Logging level (DEBUG, TRACE)
TF_CLI_ARGS  → Default global CLI arguments
TF_DATA_DIR  → Custom .terraform directory location
# (Used for advanced control)
```
