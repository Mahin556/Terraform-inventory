```hcl
# ─────────────────────────────────────────────────────
# WHAT IS INTERPOLATION? (SIMPLE EXPLANATION)
# ─────────────────────────────────────────────────────

# 1️⃣ BASIC MEANING OF INTERPOLATION
# ----------------------------------
# Interpolation = inserting or embedding a value inside another value.
#
# In easy terms:
#       "Hello, ${name}!"
#
# If name = "Mahin"
# → Result becomes: "Hello, Mahin!"
#
# You *interpolate* (insert) the value of a variable into a string.

# 2️⃣ INTERPOLATION IN PROGRAMMING
# --------------------------------
# Most languages use interpolation:
#
# Python:
#   f"Hello {name}"
#
# Bash:
#   echo "User: $USER"
#
# JavaScript:
#   `Result: ${value}`

# All of them inject variable values into text.

# ─────────────────────────────────────────────────────
# INTERPOLATION IN TERRAFORM
# ─────────────────────────────────────────────────────

# 3️⃣ TERRAFORM INTERPOLATION MEANS:
# ----------------------------------
# Using values of:
#   • variables
#   • outputs
#   • functions
#   • resource attributes
#   • current workspace
#
# INSIDE strings or Terraform expressions.

# Example:
Name = "${var.name_tag}_${terraform.workspace}"

# Terraform replaces:
#   var.name_tag           → "EC2"
#   terraform.workspace    → "dev"
#
# Final string becomes:
#       EC2_dev

# This dynamic substitution is called INTERPOLATION.

# 4️⃣ INTERPOLATION LETS YOU:
# ---------------------------
# ✔ Use variables inside strings  
# ✔ Build dynamic names (EC2_dev, EC2_prod)  
# ✔ Reference values from other resources  
# ✔ Use functions like format(), lower(), upper()  
# ✔ Make Terraform configuration dynamic and reusable  

# 5️⃣ EXAMPLES IN TERRAFORM
# -------------------------

# Insert variable value:
"${var.instance_type}"

# Combine strings:
"${var.env}-${var.app}"

# Use function + workspace:
format("%s-%s", var.app_name, terraform.workspace)

# Use resource attributes:
"${aws_instance.my_vm.public_ip}"

# 6️⃣ WHY INTERPOLATION IS IMPORTANT
# ----------------------------------
# Without interpolation, Terraform files would be:
#   • static
#   • environment-specific
#   • repetitive
#
# With interpolation:
#   • same code works for dev/test/prod
#   • dynamic outputs
#   • dynamic tags & names
#   • automatic linking between resources
```