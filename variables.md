### References:-
- https://spacelift.io/blog/how-to-use-terraform-variables#managing-terraform-state-with-spacelift-

* Make terraform code dynamic, using them you can change code config.
* Stored in memory at run time.
* Placeholder and reusable.
* See the entire terraform code as function and see variable as argument, local as function local variables, output as value function return.
* Parameterization.
* Prevent hard coding
* Types:- `string`,`number`,`bool`,`list`,`map`,`tuple`,`object`,set` (https://spacelift.io/blog/how-to-use-terraform-variables#terraform-variables-types)
    * `string`,`number`,`bool` --> simple
    * `list`,`map`,`tuple`,`object`,set` --> complex

```json
variable "region" {
    description = "value of region"
    type = string
    default = "ap-south-1"
}

provider "aws" {
    region = var.region
}
```

---

### Format specifiers

| Specifier | Meaning                                 |
| --------- | --------------------------------------- |
| `%s`      | string                                  |
| `%d`      | integer                                 |
| `%f`      | float                                   |
| `%t`      | boolean                                 |
| `%v`      | **default format (works for any type)** |


---

```hcl
variable "username" {
    type = string
}

variable "age" {
    type = number
}

variable "movies" {
    type = list
}

variable "map_" {
    type = map
}
```
```hcl
username = "mahin"
movies = ["rrr"]
map_ = {
    mahin = 22
    raza = 20
}
```
```hcl
output "result" {
  value = "Username:- ${var.username}\nAge:- ${var.age}\nMovies:-${join(",",var.movies)}\nMapping:-\n${var.map_.mahin}|${var.map_.raza}\n"
}
```

---

* Local
* Data represent in key value pair.
* Value can be **hardcoded** and be a reference to another **variable** or **resource**.

```hcl
# --------------------------------------------
# USE CASES OF LOCAL VARIABLES IN TERRAFORM
# --------------------------------------------

locals {
  # 1) Avoid repeating same value everywhere
  project_name = "my-app"

  # 2) Create computed / derived values
  full_name = "${var.env}-${var.region}-${local.project_name}"

  # 3) Maintain consistent tags
  common_tags = {
    Environment = var.env
    Project     = local.project_name
    ManagedBy   = "Terraform"
  }

  # 4) Simplify complex expressions (filtering list)
  active_servers = [
    for s in var.servers : s.name if s.enabled == true
  ]

  # 5) Naming convention standardization
  resource_prefix = "${var.env}-${var.team}-${local.project_name}"

  # 6) Convert or transform input data
  subnet_list = split(",", var.subnet_csv)

  # 7) Clean & readable code (instead of writing expressions in resources)
  bucket_name = lower("${local.project_name}-${var.env}-bucket")
}


# ------------ USING THE LOCALS ----------------

resource "aws_s3_bucket" "main" {
  # Using naming local to keep consistency
  bucket = local.bucket_name

  # Using common tags from locals
  tags = local.common_tags
}

resource "aws_iam_user" "user" {
  # Using full name derived from locals
  name = local.full_name

  tags = local.common_tags
}

resource "null_resource" "servers" {
  # Using filtered list of active servers
  triggers = {
    servers = join(",", local.active_servers)
  }
}
```

```hcl
locals {
 ami  = "ami-0d26eb3972b7f8c96"
 type = "t2.micro"
 tags = {
   Name = "My Virtual Machine"
   Env  = "Dev"
 }
 subnet = "subnet-76a8163a"
 nic    = aws_network_interface.my_nic.id
}

resource "aws_instance" "myvm" {
 ami           = local.ami
 instance_type = local.type
 tags          = local.tags
 
 network_interface {
   network_interface_id = local.nic
   device_index         = 0
 }
}

resource "aws_network_interface" "my_nic" {
 description = "My NIC"
 subnet_id   = local.subnet
 
 tags = {
   Name = "My NIC"
 }
}
```

---

* Input variables
* Using input variable we can pass value from outside of config/module.
* We can pass or change varible values before execution.
* Input variable mainly used with module to give input to module.
    * Input variable declared in module and get the value from the rool directory.
* Additionally, it is also possible to set certain attributes while declaring input variables, as below:
    * `type` — to identify the type of the variable being declared.
    * `default` — default value in case the value is not provided explicitly.
    * `description` — a description of the variable. This description is also used to generate documentation for the module.
    * `validation` — to define validation rules.
    * `sensitive` — a boolean value. If true, Terraform masks the variable’s value anywhere it displays the variable.

```hcl
#String ---> Sequence of UNICODE chars
variable "string_type" {
 description = "This is a variable of type string"
 type        = string
 default     = "Default string value for this variable"
}

#Varible also support HEReDOC
variable "string_heredoc_type" {
 description = "This is a variable of type string"
 type        = string
 default     = <<EOF
hello, this is Sumeet.
Do visit my website!
EOF
}

#NUMBR
variable "number_type" {
 description = "This is a variable of type number"
 type        = number
 default     = 42
}

#BOOLEAN
#Use in codition --> create a infra or not?
variable "boolean_type" {
 description = "This is a variable of type bool"
 type        = bool
 default     = true
}

#LIST OF STRING
# Support all data types
# at a time we can only store same type of value.
#List type input variables are particularly useful in scenarios where we need to provide multiple values of the same type, such as a list of IP addresses, a set of ports, or a collection of resource names.
variable "list_type" {
 description = "This is a variable of type list"
 type        = list(string)
 default     = ["string1", "string2", "string3"]
}

#MAP OF STRING
#key must the unique
#For example, a map can be used to specify resource tags, environment-specific settings, or configuration parameters for different modules.
variable "map_type" {
 description = "This is a variable of type map"
 type        = map(string)
 default     = {
   key1 = "value1"
   key2 = "value2"
 }
}

#OBJECT
* key value pair
* each key have different type associated.
* an object is used to define a set of parameters for a server configuration.
variable "object_type" {
 description = "This is a variable of type object"
 type        = object({
   name    = string
   age     = number
   enabled = bool
 })
 default = {
   name    = "John Doe"
   age     = 30
   enabled = true
 }
}

#TUPLE
#fixed lenght
#collection
#value can be diff types
#ordered
variable "tuple_type" {
 description = "This is a variable of type tuple"
 type        = tuple([string, number, bool])
 default     = ["item1", 42, true]
}

#SET
#unordered
#each value must be unique
#support various inbuilt operations such as union, intersection, and difference, which are used to combine or compare sets.
variable "set_example" {
 description = "This is a variable of type set"
 type        = set(string)
 default     = ["item1", "item2", "item3"]
}

#MAP OF OBJECT
#each key is associated with an object value.
#create a collection of key-value pairs, where the values are objects with defined attributes and their respective values.
#define the structure of the object values by specifying the attributes and their corresponding types within the object type definition.
variable "map_of_objects" {
  description = "This is a variable of type Map of objects"
  type = map(object({
    name = string,
    cidr = string
  }))
  default = {
    "subnet_a" = {
    name = "Subnet A",
    cidr = "10.10.1.0/24"
    },
  "subnet_b" = {
    name = "Subnet B",
    cidr = "10.10.2.0/24"
    },
  "subnet_c" = {
    name = "Subnet C",
    cidr = "10.10.3.0/24"
    }
  }
}

#LIST OF OBJECT
#value not refered by key, intead it is list of object
#ordered, indexed
variable "list_of_objects" {
  description = "This is a variable of type List of objects"
  type = list(object({
    name = string,
    cidr = string
  }))
  default = [
    {
      name = "Subnet A",
      cidr = "10.10.1.0/24"
    },
    {
      name = "Subnet B",
      cidr = "10.10.2.0/24"
    },
    {
      name = "Subnet C",
      cidr = "10.10.3.0/24"
    }
  ]
}
```
```hcl
# ---------------------------------------------------------
# DIFFERENCE BETWEEN MAP AND OBJECT IN TERRAFORM
# ---------------------------------------------------------

# MAP:
# - Key-value pair dictionary
# - All values MUST BE of the same type (all strings, all numbers, etc.)
# - Flexible keys (dynamic)
# - Good for tags, labels, generic lookups
variable "student_map" {
  type = map(string)
  default = {
    name     = "Rahul"
    city     = "Delhi"
    country  = "India"
    # All values must be string (because map(string))
  }
}


# OBJECT:
# - Structured record
# - Each attribute has a defined name AND its own data type
# - More strict and predictable than map
# - Good for fixed structured data (user info, configs, etc.)
variable "student_object" {
  type = object({
    name     = string
    age      = number
    city     = string
    subjects = list(string)
  })

  default = {
    name     = "Rahul"
    age      = 21
    city     = "Delhi"
    subjects = ["Math", "Physics"]
    # Every field can have different types
  }
}


# ---------------- SUMMARY (EASY) ----------------
# MAP:
#   - Dynamic keys
#   - One value type only (map(string), map(number))
#
# OBJECT:
#   - Fixed keys
#   - Each attribute can have its own type
#   - More strict structure
```
```hcl
# ----------------------------------------------------------
# WHAT DOES "FIXED LENGTH" MEAN IN TERRAFORM TUPLE? (THEORY)
# ----------------------------------------------------------

# A tuple in Terraform:
# - Has a FIXED number of elements (length cannot change)
# - Each position has a specific, predetermined type
# - You MUST provide values in the same order and same count
# - You cannot add/remove elements
# - You cannot reorder elements

# Example: tuple([string, number, bool])
# → This tuple has FIXED LENGTH = 3 elements
# → 1st element must be string
# → 2nd element must be number
# → 3rd element must be bool

variable "tuple_type" {
  description = "This is a variable of type tuple"

  # FIXED LENGTH TUPLE (exactly 3 elements)
  type = tuple([string, number, bool])

  # ✔ Correct → has 3 elements matching required types
  default = ["item1", 42, true]

  # ❌ Wrong → different length (4 items)
  # default = ["item1", 42, true, "extra"]

  # ❌ Wrong → different order/type
  # default = [42, "item1", true]   # type mismatch

  # Summary:
  # "Fixed length" means:
  #   - Number of items cannot change
  #   - Order cannot change
  #   - Types at each index are enforced
}
```

```hcl
variable "ami" {
 type        = string
 description = "AMI ID for the EC2 instance"
 default     = "ami-0d26eb3972b7f8c96"
 
 validation {
   condition     = length(var.ami) > 4 && substr(var.ami, 0, 4) == "ami-"
   error_message = "Please provide a valid value for variable AMI."
 }
}
 
variable "type" {
 type        = string
 description = "Instance type for the EC2 instance"
 default     = "t2.micro"
 sensitive   = true
# + instance_type                                        = (sensitive)
}
 
variable "tags" {
 type = object({
   name = string
   env  = string
 })
 description = "Tags for the EC2 instance"
 default = {
   name = "My Virtual Machine"
   env  = "Dev"
 }
}
 
variable "subnet" {
 type        = string
 description = "Subnet ID for network interface"
 default     = "subnet-76a8163a"
}

resource "aws_instance" "myvm" {
 ami           = var.ami
 instance_type = var.type
 tags          = var.tags
 
 network_interface {
   network_interface_id = aws_network_interface.my_nic.id
   device_index         = 0
 }
}
 
resource "aws_network_interface" "my_nic" {
 description = "My NIC"
 subnet_id   = var.subnet
 
 tags = {
   Name = "My NIC"
 }
}
```

---

```hcl
# ----------------------------------------------------------
# VARIABLE SUBSTITUTION IN TERRAFORM (THEORY IN COMMENTS)
# ----------------------------------------------------------

# 1) DEFAULT VALUES
# If a variable has a default value in variables.tf,
# Terraform uses it unless overridden.
#
# Example:
# variable "ami" { default = "ami-default" }


# ----------------------------------------------------------
# 2) OVERRIDING VARIABLES USING CLI:  -var
# ----------------------------------------------------------
# You can override any variable using -var arguments.
# Must repeat -var for every variable.
#
# Example:
# terraform plan \
#   -var "ami=test" \
#   -var "type=t2.nano" \
#   -var "tags={\"name\":\"MyVM\",\"env\":\"Dev\"}"
#
# Note: complex values (maps, objects) must be quoted and escaped.


# ----------------------------------------------------------
# 3) USING .tfvars FILE
# ----------------------------------------------------------
# Better approach when many variables exist.
# Example values.tfvars:
#
# ami  = "ami-0d26eb3972b7f8c96"
# type = "t2.nano"
# tags = {
#   name = "My Virtual Machine"
#   env  = "Dev"
# }
#
# Use with:
# terraform plan -var-file="values.tfvars"


# ----------------------------------------------------------
# 4) AUTO-LOADING .auto.tfvars
# ----------------------------------------------------------
# If file ends with *.auto.tfvars, Terraform loads it automatically.
#
# Example: values.auto.tfvars
# No need to pass -var-file manually.


# ----------------------------------------------------------
# 5) ENVIRONMENT VARIABLES:  TF_VAR_<variable_name>
# ----------------------------------------------------------
# Another method to set Terraform variables.
#
# Export example:
# export TF_VAR_ami=ami-0d26eb3972b7f8c96
#
# Terraform automatically maps:
# TF_VAR_ami  → variable "ami"
#
# NOTE: Good for secrets (API keys, passwords).
# Avoid storing sensitive data inside .tfvars.


# ----------------------------------------------------------
# 6) OTHER TERRAFORM ENV VARIABLES
# ----------------------------------------------------------
# TF_LOG       → Logging level (DEBUG, TRACE)
# TF_CLI_ARGS  → Default global CLI arguments
# TF_DATA_DIR  → Custom .terraform directory location
# (Used for advanced control)


# ----------------------------------------------------------
# 7) VARIABLE PRECEDENCE (HIGHEST → LOWEST)
# ----------------------------------------------------------
# 1) CLI arguments (-var)
# 2) .tfvars and *.auto.tfvars files
# 3) Environment variables (TF_VAR_)
# 4) Default values (in variable blocks)
#
# If none provided → Terraform asks in interactive mode.


# ----------------------------------------------------------
# 8) BEST PRACTICE
# ----------------------------------------------------------
# Do NOT store secrets in *.tfvars files.
# Instead, use environment variables:
#
# export TF_VAR_db_password="supersecret"
#
# Many CI/CD tools (e.g., Spacelift) use TF_VAR_ variables
# for secure secret management.
```

---

### Validation

```hcl
# -------------------------------------------------------------------
# VARIABLE VALIDATION IN TERRAFORM (THEORY WITH COMMENTS)
# -------------------------------------------------------------------

# Before Terraform introduced "variable validation",
# people used a hacky trick: force Terraform to fail
# by calling the file() function with a fake path.
# If the condition is invalid → Terraform throws an error.
#
# -------------------- OLD HACKY VALIDATION --------------------------
locals {
  vpc_cidr = "10.0.0.0/16"

  # BAD PRACTICE (old method)
  # If mask <16 or >30 → try to read a non-existent file → Terraform fails
  vpc_cidr_validation = split("/", local.vpc_cidr)[1] < 16 ||
                        split("/", local.vpc_cidr)[1] > 30
                        ? file(format("\nERROR: VPC CIDR %s must be /16 to /30", local.vpc_cidr))
                        : null
}

# Result:
# - If CIDR is valid  → Terraform applies normally
# - If CIDR is invalid → Error comes from file() → confusing message


# -------------------------------------------------------------------
# TERRAFORM VARIABLE VALIDATION (MODERN, CLEAN, RECOMMENDED)
# -------------------------------------------------------------------
# Terraform now supports proper validation inside variable blocks.
# This gives clean errors, clear messages, and avoids hacks.

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/8"

  validation {
    # CONDITION:
    # CIDR suffix must be >16 AND <30
    condition = split("/", var.cidr_block)[1] > 16 &&
                split("/", var.cidr_block)[1] < 30

    # CUSTOM ERROR MESSAGE:
    error_message = "Your VPC CIDR mask must be between /16 and /30."
  }
}

# If cidr_block = "10.0.0.0/8"
# → Terraform fails with clean error:
#     "Your VPC CIDR mask must be between /16 and /30."


# -------------------------------------------------------------------
# ADVANCED VALIDATION: CHECK CIDR FORMAT
# -------------------------------------------------------------------
# We can validate the structure of the string itself.

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    # CONDITION:
    # - Must contain "/"
    # - Must have exactly 4 octets (length of split(".") == 4)
    condition = strcontains(var.cidr_block, "/") &&
                length(split(var.cidr_block, ".")) == 4

    # ERROR IF FAILS:
    error_message = "Your VPC CIDR does not follow correct CIDR format."
  }
}

# -------------------------------------------------------------------
# SUMMARY (EASY TO REMEMBER)
# -------------------------------------------------------------------
# OLD WAY (BAD):
#   - Use file() with fake path to force an error.
#   - Confusing and ugly errors.
#
# NEW WAY (GOOD):
#   - validation { condition + error_message }
#   - Clean, readable, accurate errors.
#   - Helps catch mistakes before apply.
```

---

### Sensative values
```hcl
# -------------------------------------------------------------------
# SENSITIVE VARIABLES IN TERRAFORM (THEORY EXPLAINED IN COMMENTS)
# -------------------------------------------------------------------
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

---

```hcl
###############################################
#                OUTPUT VARIABLES
###############################################
# Use-case:
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


###############################################
#        VARIABLES INSIDE for_each LOOPS
###############################################
# Example: Create multiple subnets with different:
#   - CIDR blocks
#   - Availability Zones
#
# For such use-cases, we use:
#   map(object({
#       cidr = string
#       az   = string
#   }))
#
# This allows complex structured data.


###############################################
#      COMPLEX VARIABLE DECLARATION
###############################################
variable "my_subnets" {
  type = map(object({
    cidr = string   # Each subnet must define a CIDR block
    az   = string   # And the availability zone
  }))

  description = "Subnets for My VPC"
}


###############################################
#           .tfvars INITIALIZATION
###############################################
# We provide actual dynamic values here.
# Keys "a", "b", "c", "d", "e" uniquely identify each subnet.

# my_subnets.tfvars
my_subnets = {
  "a" = {
    cidr = "10.0.1.0/26"
    az   = "eu-central-1a"
  },
  "b" = {
    cidr = "10.0.2.0/26"
    az   = "eu-central-1a"
  },
  "c" = {
    cidr = "10.0.3.0/26"
    az   = "eu-central-1b"
  },
  "d" = {
    cidr = "10.0.4.0/26"
    az   = "eu-central-1c"
  },
  "e" = {
    cidr = "10.0.5.0/26"
    az   = "eu-central-1b"
  }
}


###############################################
#            CREATE SUBNETS USING for_each
###############################################
# for_each = var.my_subnets:
#   - Iterates over each key-value pair
#   - each.key   → "a", "b", "c", etc.
#   - each.value → the object {cidr="", az=""}

resource "aws_subnet" "my_subnets" {
  for_each          = var.my_subnets       # Loop through all subnets
  vpc_id            = aws_vpc.my_vpc.id     # Reference VPC
  cidr_block        = each.value.cidr       # Assign CIDR block
  availability_zone = each.value.az         # Assign AZ

  tags = {
    Name = "Subnet - ${each.value.az}"      # Dynamic tag per subnet
  }
}

# RESULT:
# One single resource block creates 5 subnets.
# Terraform will generate:
#   aws_subnet.my_subnets["a"]
#   aws_subnet.my_subnets["b"]
#   aws_subnet.my_subnets["c"]
#   aws_subnet.my_subnets["d"]
#   aws_subnet.my_subnets["e"]
```

---

### Bestpractices

```hcl
###############################################
#        TERRAFORM VARIABLES BEST PRACTICES
#        (With Theory in Comments)
###############################################

###############################################
# 1. USE DESCRIPTIVE VARIABLE NAMES
###############################################
# Good names improve readability and avoid confusion.
# Avoid vague names like "x", "var1", "server".
# Prefer: instance_type, environment, db_password.

variable "instance_type" {
  type        = string
  description = "EC2 instance type for web servers"
}


###############################################
# 2. ORGANIZE YOUR VARIABLES
###############################################
# Group variables logically using:
#   - variables.tf  → all variable definitions
#   - terraform.tfvars → actual values
#   - env-specific files: dev.tfvars, prod.tfvars
#
# This keeps code clean and reusable.


###############################################
# 3. SPECIFY VARIABLE TYPES
###############################################
# Always specify types for better validation and clarity.
# Examples: string, number, bool, list(string), map(object)

variable "allowed_ips" {
  type        = list(string)   # Explicit type
  description = "List of IPs allowed in security group"
}


###############################################
# 4. IMPLEMENT VARIABLE VALIDATIONS
###############################################
# Helps catch mistakes before `terraform apply`.

variable "port" {
  type = number

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}


###############################################
# 5. SECURE SENSITIVE VARIABLES
###############################################
# Prevents passwords, keys, and secrets from being printed.

variable "db_password" {
  type        = string
  sensitive   = true     # Hide value in logs/output
  description = "Database master password"
}


###############################################
# 6. USE DEFAULT VALUES WHEN POSSIBLE
###############################################
# Reduces user input and makes modules easier to reuse.

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default AWS region"
}


###############################################
# 7. USE OPTIONAL OBJECT ATTRIBUTES
###############################################
# Reduces required input for complex variables.
# Example: optional keys in an object.

variable "server_config" {
  type = object({
    size       = string
    backup     = optional(bool, false) # Optional field with default
    monitoring = optional(bool)        # Optional, no default
  })
}


###############################################
# 8. WRITE DOCUMENTATION FOR VARIABLES
###############################################
# Use the "description" field, and maintain README docs.
# This helps teams understand complex objects and maps.


###############################################
# 9. USE ENVIRONMENT VARIABLES IN CI/CD
###############################################
# Example:
#   export TF_VAR_db_password="supersecret"
#
# The name must match: TF_VAR_<variable_name>
# Useful for secrets and dynamic values during automation.


###############################################
# 10. USE DYNAMIC CREDENTIALS, AVOID STATIC SECRETS
###############################################
# Do NOT hardcode:
#   - AWS access keys
#   - Database passwords
#
# Instead use:
#   - AWS IAM roles
#   - HashiCorp Vault
#   - SSM Parameter Store
#   - OIDC tokens
#   - Temporary credentials
###############################################
```

---

```hcl

variable "bucket_prefix" {
  type    = string
  default = "mybucketname"
}

locals {
  bucket_name = "${var.bucket_prefix}-bucket1"
  bucket_info={
    name="bucket-project"
    env="prod"
  }
  buckets=[for i in range(1,6): "${local.bucket_info.name}-${i}"]
  env         = "dev"
  env_tags = {
    envname = "dev"
    envteam = "devteam"
  }
  users ={
    "mahin":1,
    "raza":2,
    "sam":3
  }
  list_=[1,2,3,4,5,6,7,8,9]
  prefix_elements = [for elem in ["a", "b", "c"] : format("Hello %s", elem)]
  prefix_elements1 = [for i in local.list_ : i if i%2==0]
}

output "demo3" {
  value=local.buckets
}
/*-> OUTPUT
demo3     = [
      + "bucket-project-1",
      + "bucket-project-2",
      + "bucket-project-3",
      + "bucket-project-4",
      + "bucket-project-5",
    ]
*/


output "demo" {
  value = [for i in keys(local.env_tags) : i] #keys
}
/*-> OUTPUT
demo      = [
      + "envname",
      + "envteam",
    ]
*/

output "dem2" {
  value = [for i in values(local.env_tags) : i] #values
}
/*-> OUTPUT
dem2      = [
      + "dev",
      + "devteam",
    ]
*/

output "key_value" {
  value = {for key,value in local.env_tags: key=>value}
}
/*-> OUTPUT
 key_value = {
      + envname = "dev"
      + envteam = "devteam"
    }
*/

output "Demo" {
  value = [for user,i in local.users : "${user} id is ${i}"] #value and key both
}
/*-> OUTPUT
Demo      = [
      + "mahin id is 1",
      + "raza id is 2",
      + "sam id is 3",
    ]
*/

output "demo1" {
  value = local.prefix_elements1  # values
}
/*-> OUTPUT
demo1     = [
      + 2,
      + 4,
      + 6,
      + 8,
    ]
*/

variable "res_tags" {
  type = map(string)
  default = {
    dept = "finance",
    type = "app"
  }
}

variable "res_tags1" {
  type = map(string)
  default = {
    dept1 = "finance",
    type1 = "app"
  }
}

 
locals {
  all_tags = {
    env       = "dev",
    terraform = true
  }
  applied_tags = merge(var.res_tags, var.res_tags1, local.all_tags)
}


output "res_tags" {
  value = var.res_tags
}
/*-> OUTPUT
res_tags  = {
      + dept = "finance"
      + type = "app"
    }
*/

resource "aws_s3_bucket" "tagsbucket" {
  bucket = "tags-bucket"
  tags = local.applied_tags
}

 
output "out_tags" {
  value = local.applied_tags
}
/*-> OUTPUT
out_tags  = {
      + dept      = "finance"
      + dept1     = "finance"
      + env       = "dev"
      + terraform = true
      + type      = "app"
      + type1     = "app"
    }
*/

```