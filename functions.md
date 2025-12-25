### References:-
- https://spacelift.io/blog/terraform-functions-expressions-loops#deploying-terraform-resources-with-spacelift
- https://spacelift.io/blog/terraform-merge-function
- https://spacelift.io/blog/terraform-flatten#what-is-the-flatten-function-in-terraform
- https://spacelift.io/blog/terraform-lookup#terrafrom-lookup-vs-element-function
- https://spacelift.io/blog/terraform-join#terraform-join-examples
- https://spacelift.io/blog/terraform-path#types-of-path-references
- https://spacelift.io/blog/terraform-length-function#advanced-methods-of-using-the-length-function
- https://spacelift.io/blog/terraform-element-function#how-does-the-element-function-work

---

* Function is a built in reusable code block perform specify.
* Implemeny DRy principle
* Perofrm specific operation

Terraform has **14 categories** of functions:

1. String Functions
2. Numeric Functions
3. Collection Functions
4. Encoding Functions
5. Filesystem Functions
6. Date & Time Functions
7. Crypto & Hash Functions
8. IP Network Functions
9. Type Conversion Functions
10. Structural Manipulation (Objects & Maps)
11. Dynamic & Experimental Functions
12. Terraform State/Runtime Functions
13. Language Meta Functions
14. Other Utility Functions

I will give:

✔ Function name
✔ Short explanation
✔ Simple example
✔ Result

---

# ⭐ 1. **STRING FUNCTIONS**

| Function       | Example                            | Result                |
| -------------- | ---------------------------------- | --------------------- |
| `upper()`      | `upper("hello")`                   | `"HELLO"`             |
| `lower()`      | `lower("Hello")`                   | `"hello"`             |
| `title()`      | `title("my app")`                  | `"My App"`            |
| `chomp()`      | `chomp("hello\n")`                 | `"hello"`             |
| `trim()`       | `trim(" abc ")`                    | `"abc"`               |
| `trimspace()`  | `trimspace("  hi  ")`              | `"hi"`                |
| `substr()`     | `substr("abcdef", 1, 3)`           | `"bcd"`               |
| `replace()`    | `replace("a-b-c", "-", "_")`       | `"a_b_c"`             |
| `regex()`      | `regex("[0-9]+", "abc123")`        | `"123"`               |
| `regexall()`   | `regexall("[0-9]", "a1b2c3")`      | `["1","2","3"]`       |
| `format()`     | `format("Hello %s", "John")`       | `"Hello John"`        |
| `formatlist()` | `formatlist("item %s", ["a","b"])` | `["item a","item b"]` |
| `split()`      | `split(",", "a,b,c")`              | `["a","b","c"]`       |
| `join()`       | `join("-", ["a","b"])`             | `"a-b"`               |
| `startswith()` | `startswith("abc", "a")`           | `true`                |
| `endswith()`   | `endswith("abc", "c")`             | `true`                |
| `contains()`   | `contains(["a","b"], "b")`         | `true`                |
| `strrev()`     | `strrev("abc")`                    | `"cba"`               |
| `indent()`     | `indent("hello", 4)`               | `"    hello"`         |
| `trim()`       | `trim("!!abc!!", "!")`             | `"abc"`               |

```bash
#substr() is a Terraform string function used to extract a portion (substring) from a larger string.
#substr(string, offset, length)
    #string → input string
    #offset → starting index (0-based)
    #length → number of characters to extract
substr("learning", 0, 4) #--->"lear"
substr("hello", 10, 2) #--->error
substr("hello", 3, 10) #--->lo
substr("abcdef", -3, 2) #--->de
substr(12345, 1, 2) #→ ERROR ---> can't work on non string

locals {
  string1       = "str1"
  string2       = "str2"
  int1          = 3
  apply_format  = format("This is %s", local.string1)
  apply_format2 = format("%s_%s_%d", local.string1, local.string2, local.int1)
}

locals {
  format_list = formatlist("Hello, %s!", ["A", "B", "C"])
}

output "format_list" {
  value = local.format_list
}

#   + format_list    = [
#       + "Hello, A!",
#       + "Hello, B!",
#       + "Hello, C!",
#     ]


locals {
  join_string = join(",", ["a", "b", "c"]) #join the list
}



variable "word_list" {
  default = [
    "Critical\n",
    "failure\n",
    "teapot\n",
    "broken\n"
  ]
}
output "cleaned_words" {
  value = [for w in var.word_list : chomp(w)]
  # RESULT → ["Critical", "failure", "teapot", "broken"]
}

```

```hcl
###############################################
# TERRAFORM split() FUNCTION — THEORY + EXAMPLES
###############################################
#
# split(delimiter, string)
#
# → Opposite of join()
# → Takes ONE STRING and splits it into a LIST
# → Split happens every time the delimiter appears
#
# Example:
#   split("-", "a-b-c")  → ["a", "b", "c"]
#
###############################################



###############################################
# EXAMPLE 1 — Splitting a comma-separated string
###############################################
#
# Input string: "this, and, that"
# Delimiter: ", "
#
locals {
  words = split(", ", "this, and, that")
}

# Result:
# words = ["this", "and", "that"]
#
# Useful when API returns comma-separated values.



###############################################
# EXAMPLE 2 — Splitting a PATH string (Azure ID)
###############################################
#
# Azure resource IDs look like:
#
# /subscriptions/1234/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/GatewaySubnet
#
# "/" is the delimiter → each path segment becomes a list element
#
locals {
  subnet_id = "/subscriptions/1234/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/GatewaySubnet"

  split_list = split("/", local.subnet_id)
}

# split_list will be:
# [
#   "",               # index 0 (empty because ID starts with "/")
#   "subscriptions",
#   "1234",
#   "resourceGroups",
#   "my-rg",
#   "providers",
#   "Microsoft.Network",
#   "virtualNetworks",
#   "my-vnet",        # <-- index 8 (this is usually the VNET name)
#   "subnets",
#   "GatewaySubnet"
# ]



###############################################################
# EXAMPLE 3 — Extracting a Specific Element After split()
###############################################################
#
# Common in Azure, because path segments contain names you need.
#
output "gateway_network_name" {
  value = split("/", azurerm_virtual_network_gateway.azure_vng.ip_configuration[0].subnet_id)[8]
}

# This extracts the 9th element → "my-vnet"



###############################################
# EXAMPLE 4 — Using split() with Variables
###############################################
variable "path_string" {
  default = "/a/b/c/d/e"
}

locals {
  parts = split("/", var.path_string)
}

# parts = ["", "a", "b", "c", "d", "e"]



###############################################
# EXAMPLE 5 — Using split() + index for dynamic logic
###############################################
locals {
  fqdn = "app.dev.example.com"

  fqdn_parts = split(".", local.fqdn)
  env        = local.fqdn_parts[1]    # "dev"
  domain     = join(".", slice(local.fqdn_parts, 2, length(local.fqdn_parts)))
}

# env    = "dev"
# domain = "example.com"
```

```hcl
#Join function take list of string and return a single string.
#join(delimiter, list)
#delimiter --> used between items in resulting string
#list --->list of element to concatinate

> join(", ", ["this", "and", "that"])
"this, and, that"
>

#Building a file path (or URL) from parts
variable "env" {
  type    = string
  default = "prod"
}

locals {
  path_parts = ["srv", var.env, "nginx"]
}

output "config_path" {
  value = join("/", local.path_parts) # -> "srv/prod/nginx"
}


> join("/", ["https://api.example.com", "v1", "users"])
"https://api.example.com/v1/users"


#Creating a resource tag
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"

  tags = {
    Name        = join("-", ["project", var.env, "bucket"])
    Environment = var.env
  }
}


# Turning dynamic values into a comma-separated string
# Imagine a module or resource that needs a CSV string of IPs
# (some providers/modules accept a single comma-separated string)
locals {
  app_ips = [
    "10.0.1.10",
    "10.0.1.11",
    "10.0.1.12",
  ]
}

output "ip_csv" {
  value = join(", ", local.app_ips) # -> "10.0.1.10, 10.0.1.11, 10.0.1.12"
}

#If your elements aren’t strings (for example, numbers), you’d convert them first, e.g., 
join(", ", [for n in local.ports : tostring(n)])

#Joining Azure storage accounts
provider "azurerm" {
 features = {}
}

# Define variables
variable "storage_account_names" {
 type    = list(string)
 default = ["storageaccount1", "storageaccount2", "storageaccount3"]
}

# Create Azure Storage Accounts
resource "azurerm_storage_account" "example" {
 count                    = length(var.storage_account_names)
 name                     = var.storage_account_names[count.index]
 resource_group_name      = "example-resource-group"
 location                 = "East US"
 account_tier             = "Standard"
 account_replication_type = "LRS"
}

# Join the resource IDs of the created storage accounts into a comma-separated string
output "joined_storage_account_ids" {
 value = join(", ", [for acc in azurerm_storage_account.example : acc.id])
}
```

---

# ⭐ 2. **NUMERIC FUNCTIONS**

| Function   | Example        | Result |
| ---------- | -------------- | ------ |
| `min()`    | `min(3, 5, 1)` | `1`    |
| `max()`    | `max(3, 5, 1)` | `5`    |
| `ceil()`   | `ceil(4.2)`    | `5`    |
| `floor()`  | `floor(4.8)`   | `4`    |
| `abs()`    | `abs(-10)`     | `10`   |
| `pow()`    | `pow(2, 3)`    | `8`    |
| `signum()` | `signum(-5)`   | `-1`   |

---

# 3. **COLLECTION FUNCTIONS (LIST, MAP, SET)**

| Function     | Example                      | Result      |
| ------------ | ---------------------------- | ----------- |
| `length()`   | `length([1,2,3])`            | `3`         |
| `element()`  | `element(["a","b","c"], 1)`  | `"b"`       |
| `slice()`    | `slice(["a","b","c"], 0, 2)` | `["a","b"]` |
| `concat()`   | `concat([1],[2])`            | `[1,2]`     |
| `flatten()`  | `flatten([[1,2],[3]])`       | `[1,2,3]`   |
| `distinct()` | `distinct([1,1,2])`          | `[1,2]`     |
| `sort()`     | `sort(["c","a"])`            | `["a","c"]` |
| `reverse()`  | `reverse(["a","b"])`         | `["b","a"]` |
| `keys()`     | `keys({a=1,b=2})`            | `["a","b"]` |
| `values()`   | `values({a=1,b=2})`          | `[1,2]`     |
| `range()`    | `range(2,6)`                 | `[2,3,4,5]` |
| `merge()`    | `merge({a=1},{b=2})`         | `{a=1,b=2}` |
| `lookup()`   | `lookup({a=1},"a")`          | `1`         |
| `contains()` | `contains(["a","b"], "b")`   | `true`      |
| `zipmap()`   | `zipmap(["a","b"], [1,2])`   | `{a=1,b=2}` |


```hcl
###############################################
# Terraform length() Function – Full Explanation
# (All theory written as comments)
###############################################

###############################################
# What are Terraform Functions?
# ---------------------------------------------
# Terraform provides many built-in functions to
# process and transform data dynamically.
#
# These functions improve reusability and remove
# hardcoding by enabling:
#   - String operations (join, split, replace)
#   - Number operations (ceil, max, min)
#   - Collection operations (length, flatten, keys)
#   - Time-based operations (timestamp, timeadd)
#   - Encoding/format conversions (base64encode, jsonencode)
#
# Terraform functions work well with:
#   - expressions
#   - for loops
#   - for_each
#   - count
#
# This makes your IaC scalable, flexible, and more maintainable.
###############################################


###############################################
# What is the length() Function?
# ---------------------------------------------
# length(value)
#
# It returns:
#   - number of characters (if value is a string)
#   - number of elements (if value is a list)
#   - number of keys (if value is a map)
#
# Great for:
#   - validations
#   - dynamic count creation
#   - conditional logic
#   - filtering lists/maps
###############################################


###############################################
# 1. Using length() with a STRING
###############################################

variable "mystring" {
  # "helloworld" → 10 characters
  default = "helloworld"
}

output "number_in_string" {
  # length("helloworld") = 10
  value = length(var.mystring)
}

output "is_string_too_long" {
  # Using condition with length()
  # If string length > 5 → "too long"
  value = length(var.mystring) > 5 ? "string is too long" : "string is valid"
}


###############################################
# 2. Using length() with a LIST
###############################################

variable "mylist" {
  # list has 2 elements
  default = ["hello", "world"]
}

output "number_in_list" {
  # length(["hello", "world"]) = 2
  value = length(var.mylist)
}

variable "subnet_ids" {
  # Only 1 subnet → triggers validation failure condition
  default = ["subnet-1"]
}

output "validate_subnet" {
  # Require at least 2 subnets for HA networks
  value = length(var.subnet_ids) >= 2 ? 
          "Valid subnet count" : 
          "Error: At least 2 subnets required"
}


###############################################
# 3. Using length() with a MAP
###############################################

variable "mymap" {
  # Map has 2 keys
  default = {
    Map1 = "value1"
    Map2 = "value2"
  }
}

output "number_in_map" {
  # length(map) = number of keys = 2
  value = length(var.mymap)
}


###############################################
# 4. length() with Map Filtering
# ---------------------------------------------
# Using for-expression + condition + length()
# Count only keys where value == "admin"
###############################################

variable "users" {
  default = {
    goku   = "admin"
    gohan  = "user"
    vegeta = "admin"
    trunks = "user"
  }
}

output "admin_count" {
  value = length({
    for k, v in var.users :
    k => v
    if v == "admin"    # filter only admin users
  })
  # Output → 2 admins (goku & vegeta)
}


###############################################
# Summary:
# ----------
# length() is used to:
#   - Validate sizes of lists/maps
#   - Count filtered items
#   - Drive dynamic resource creation
#   - Create conditional logic
#   - Avoid errors by checking empty inputs
#
# Works with:
#   ✔️ Strings
#   ✔️ Lists
#   ✔️ Maps
###############################################
```
```hcl
#Creating a virtual machine for each VM size
variable "vm_sizes" {
  type    = list(string)
  default = ["Standard_B1s", "Standard_B2ms", "Standard_B4ms"]
}

resource "azurerm_linux_virtual_machine" "main" {
  count                 = length(var.vm_sizes)
  name                  = "example-vm-${count.index}"
  location              = "East US"
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_sizes[count.index]
  admin_username        = "adminuser"
  admin_password        = "adminpass"

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

#---


#Creating multiple disks based on the number of disk sizes listed
variable "disk_sizes" {
  type    = list(string)
  default = ["Standard_LRS", "Premium_LRS", "StandardSSD_LRS"]
}

resource "azurerm_managed_disk" "my_disk" {
  count                 = length(var.disk_sizes)
  name                  = "example-disk-${count.index}"
  location              = "East US"
  resource_group_name   = var.rg_name
  storage_account_type = var.disk_sizes[count.index]
  disk_size_gb          = 50
}

#Creating multiple VMs with key/values from a map
variable "vmconfig" {
  type = map(object({
    size      = string
    admin_username = string
    admin_password = string
  }))
  default = {
    "vm1" = {
      size             = "Standard_DS1_v2"
      admin_username   = "adminuser"
      admin_password   = "adminpass"
    },
    "vm2" = {
      size             = "Standard_DS2_v2"
      admin_username   = "adminuser"
      admin_password   = "adminpass"
    }
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = length(var.vmconfig)

  name                = "${keys(var.vmconfig)[count.index]}"
  resource_group_name = "rg_name"
  location            = "East US"
  size                = var.vmconfig[values(var.vmconfig)[count.index]].size
  admin_username      = var.vmconfig[values(var.vmconfig)[count.index]].admin_username
  admin_password      = var.vmconfig[values(var.vmconfig)[count.index]].admin_password
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]
}

resource "azurerm_network_interface" "nic" {
  count = length(var.vmconfig)

  name                            = "nic-${keys(var.vmconfig)[count.index]}"
  location                        = "East US"
  resource_group_name             = "rg_name"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "mysub"
  resource_group_name  = "rg_name"
  virtual_network_name = "mynet"
  address_prefixes     = ["10.0.0.0/24"]
}


# Using length() to Count Resources Dynamically
# ---------------------------------------------------------
# The length() function can also count how many resources
# were created by Terraform. This is very useful when:
#   - resources are created using count or for_each
#   - you want to validate total resources created
#   - you need outputs for monitoring/reporting
# Count How Many Virtual Machines Are Created
# ---------------------------------------------------------
# If azurerm_virtual_machine.myvm was created using count
# or for_each, Terraform stores it as a LIST of resources.
#
# Therefore, length() tells us exactly how many VMs exist.

output "num_of_az_virtual_machines" {
  value = length(azurerm_virtual_machine.myvm)
  # Example:
  # If myvm = { 0 = vm1, 1 = vm2, 2 = vm3 }
  # length(...) = 3
}

```
```hcl

############################################################
# 1. CONDITIONALLY CREATE A NETWORK SECURITY GROUP (NSG)
# ------------------------------------------------------------
# If the subnets list has ANY items -> create 1 NSG.
# If subnets list is empty -> create ZERO NSGs.
#
# length(var.subnets) > 0 ? 1 : 0
#
# This pattern prevents unnecessary NSG resources.
############################################################

variable "subnets" {
  type    = list(string)
  default = ["subnet1", "subnet2"]
}

resource "azurerm_network_security_group" "subnet_example" {
  count               = length(var.subnets) > 0 ? 1 : 0
  name                = "azure-net-nsg"
  location            = "East US"
  resource_group_name = var.rg_name
}



############################################################
# 2. VALIDATE CIDR BLOCK COUNT BEFORE CREATING VNET
# ------------------------------------------------------------
# A virtual network requires at least 1 CIDR.
# If the list has CIDRs -> create VNET.
# If list is empty -> skip VNET creation.
#
# This prevents invalid deployments.
############################################################

variable "cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet_example" {
  count               = length(var.cidr_blocks) > 0 ? 1 : 0
  name                = "example-vnet"
  location            = "East US"
  resource_group_name = var.rg_name
  address_space       = var.cidr_blocks
}



############################################################
# 3. DYNAMIC AZURE ROLE ASSIGNMENTS USING length() + count
# ------------------------------------------------------------
# We loop through the user list.
# For each user, we create a role assignment.
#
# count = length(var.users)
# principal_id = var.users[count.index]
#
# This automatically creates correct number of RBAC entries.
############################################################

variable "users" {
  default = [
    "darthvader@mycompany.com",
    "obiwan@mycompany.com"
  ]
}

resource "azurerm_role_assignment" "rbac" {
  count                = length(var.users)
  scope                = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  role_definition_name = "Contributor"
  principal_id         = var.users[count.index]
}



############################################################
# 4. VALIDATE SECRETS BEFORE CREATING KEY VAULT ACCESS POLICY
# ------------------------------------------------------------
# If there are no secrets -> do not create any access policy.
#
# Useful to avoid empty or misconfigured Key Vault policies.
############################################################

variable "secrets" {
  type    = list(string)
  default = ["secret1", "secret2"]
}

resource "azurerm_key_vault" "akv" {
  name                = "example-keyvault"
  location            = "East US"
  resource_group_name = var.rg_name
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "akv_policy" {
  count               = length(var.secrets) > 0 ? 1 : 0
  key_vault_id        = azurerm_key_vault.akv.id
  tenant_id           = var.tenant_id
  object_id           = var.object_id
  secret_permissions  = ["get", "list"]
}



############################################################
# 5. ENFORCE STORAGE ACCOUNT NAME RULES USING length()
# ------------------------------------------------------------
# Storage account name rules:
#   - must be lowercase
#   - only letters & numbers
#   - max length = 24 chars
#
# Logic:
#   If length > 24 → truncate to 24 chars
#   Else → use as-is (lowercased)
#
# Uses:
#   length(), substr(), lower()
############################################################

variable "storage_account_name_prefix" {
  type    = string
  default = "MyTestStorageAccount1"
}

resource "azurerm_storage_account" "storage-example" {
  name = length(var.storage_account_name_prefix) > 24 ?
    substr(lower(var.storage_account_name_prefix), 0, 24) :
    lower(var.storage_account_name_prefix)

  resource_group_name      = "rg_name"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    ignore_changes = [name]
  }
}

```

```hcl
range(max)
range(start, limit)
range(start, limit, step)
#https://developer.hashicorp.com/terraform/language/functions/range

locals {
  range_one_arg    = range(3)          # [0,1,2]
  range_two_args   = range(1, 3)       # [1,2]
  range_three_args = range(1, 13, 3)   # [1,4,7,10]
}


variable "name_counts" {
  type    = map(number)
  default = {
    "foo" = 2
    "bar" = 4
  }
}

locals {
  expanded_names = {
    for name, count in var.name_counts : name => [
      for i in range(count) : format("%s%02d", name, i)
    ]
  }
}
output "expanded_names" {
  value = local.expanded_names
}

locals {
  list_length   = length([10, 20, 30])
  string_length = length("abcdefghij")
}
output "name" {
  value = local.list_length
}


locals {
  unflatten_list = [[1, 2, 3], [4, 5], [6]]
  flatten_list   = flatten(local.unflatten_list)
}
output "name" {
  value = local.flatten_list
}

#keys(map) & values(map)
locals {
  key_value_map = { key1 = "value1", key2 = "value2" }
  key_list      = keys(local.key_value_map)
  value_list    = values(local.key_value_map)
}


#slice(list, start, end) — SUBLIST (end is exclusive)
locals {
  slice_list = slice([1, 2, 3, 4], 2, 4)  # → [3,4]
}


#lookup(map, key, fallback)
locals {
  a_map          = { key1 = "value1", key2 = "value2" }
  lookup_in_map  = lookup(local.a_map, "key1", "default")
}

#concat(list1, list2, ...)
locals {
  concat_list = concat([1,2,3], [4,5,6])
}

output "name" {
  value = local.concat_list
}


#merge(map1, map2, ...)
# NOTE: When keys overlap, later maps overwrite earlier ones.

locals {
  b_map     = { key1 = "value1", key2 = "value2" }
  c_map     = { key3 = "value3", key4 = "value4" }
  final_map = merge(local.b_map, local.c_map)
}


#zipmap(keys_list, values_list) → COMBINE INTO MAP
locals {
  key_zip    = ["a", "b", "c"]
  value_zip  = [1, 2, 3]
  zip_map    = zipmap(local.key_zip, local.value_zip)
}
output "name" {
  value = local.zip_map
}

  <!-- + name = {
      + a = 1
      + b = 2
      + c = 3
    } -->


locals {
  map1 = {
    luke  = "jedi"
    yoda  = "jedi"
    darth = "sith"
  }

  map2 = {
    quigon     = "jedi"
    palpantine = "sith"
    hansolo    = "chancer"
  }

  merged_map = merge(local.map1, local.map2)
}

# RESULT:
# {
#   luke       = "jedi"
#   yoda       = "jedi"
#   darth      = "sith"
#   quigon     = "jedi"
#   palpantine = "sith"
#   hansolo    = "chancer"
# }


###############################################################
# MERGING MAPS WITH CONFLICTING KEYS
###############################################################
# LAST map overrides earlier ones.

locals {
  mapA = {
    a = 1
    b = 2
  }

  mapB = {
    b = 3   # overrides mapA.b
    c = 4
  }

  merged = merge(local.mapA, local.mapB)
}

# RESULT:
# { a = 1, b = 3, c = 4 }


###############################################################
# MERGING LISTS OF OBJECTS (NO DIRECT MERGE)
###############################################################
# THEORY:
# - Terraform cannot merge lists directly.
# - Convert lists → maps using a "for" expression.
# - Then merge maps.
# - Or simply concat lists depending on requirement.

locals {
  list1 = [
    { key = "luke",  value = "jedi" },
    { key = "yoda",  value = "jedi" }
  ]

  list2 = [
    { key = "darth", value = "sith" },
    { key = "palp",  value = "sith" }
  ]

  # Convert list → map
  as_map = {
    for item in concat(local.list1, local.list2) :
    item.key => item
  }

  # Convert map → list (final merged list)
  merged_list = values(local.as_map)
}

# RESULT:
# [
#   { key = "luke",  value = "jedi" },
#   { key = "yoda",  value = "jedi" },
#   { key = "darth", value = "sith" },
#   { key = "palp",  value = "sith" }
# ]



###############################################################
# MERGING TAGS (COMMON USE CASE)
###############################################################

locals {
  default_tags = {
    Environment = "Production"
    Project     = "MyProject"
  }

  extra_tags = {
    Department = "Engineering"
    CostCenter = "12345"
  }

  merged_tags = merge(local.default_tags, local.extra_tags)
}

resource "aws_instance" "example" {
  ami           = "ami-xyz"
  instance_type = "t2.micro"

  tags = local.merged_tags
}

# RESULT:
# {
#   Environment = "Production"
#   Project     = "MyProject"
#   Department  = "Engineering"
#   CostCenter  = "12345"
# }


###############################################################
# SHALLOW MERGE VS DEEP MERGE (VERY IMPORTANT)
###############################################################
# merge() is ALWAYS SHALLOW.
#
# Shallow merge:
#   Overwrites an entire nested map.
#
# For example:

locals {
  a = {
    tags = {
      env = "prod"
    }
  }

  b = {
    tags = {
      owner = "dev"
    }
  }

  merged = merge(local.a, local.b)
}

# result:
# {
#   tags = { owner = "dev" }     # FULL REPLACEMENT
# }
#
# terraform DOES NOT produce:
# {
#   tags = {
#     env   = "prod",
#     owner = "dev"
#   }
# }
#
# That would be a DEEP MERGE — not supported natively.


###############################################################
# HOW TO DO A "DEEP MERGE" (CUSTOM IMPLEMENTATION)
###############################################################
# You must write your own recursive merge or use flatten + for.

locals {
  deep_merged = merge(
    local.a,
    {
      tags = merge(local.a.tags, local.b.tags)
    }
  )
}

# RESULT:
# {
#   tags = {
#     env   = "prod",
#     owner = "dev"
#   }
# }

```
```hcl
###############################################
# Best Practices for Terraform merge()
###############################################
#
# 1. Key Precedence (Right-most Wins)
#    - When two maps contain the same key,
#      the value from the LAST map in merge()
#      overrides all earlier ones.
#
#      Example:
#         merge({a=1}, {a=2}) → {a=2}
#
#    - Use this intentionally to layer:
#         defaults → env overrides → local overrides
#
# 2. Keep Types Consistent
#    - All merge() arguments MUST be maps.
#    - If values come from dynamic variables,
#      wrap them with tomap() to avoid type mismatch.
#
#      Example:
#         merge(local.base, tomap(var.extra))
#
# 3. Ideal for Module Inputs
#    - Combine global defaults + env-specific values +
#      optional overrides before passing to modules.
#
#      Example:
#         module "server" {
#           tags = merge(local.default_tags, var.env_tags)
#         }
#
# 4. Avoid Null Maps
#    - merge(null) will error.
#    - Use the null-coalescing operator ?? to protect optional vars.
#
#      Example:
#         merge(local.base, var.extra_tags ?? {})
#
# 5. Remember: merge() is SHALLOW
#    - Nested maps are not merged; they are replaced.
#      Example:
#         merge(
#           {settings = {a=1, b=2}},
#           {settings = {b=3}}
#         )
#         → {settings = {b=3}}  # a=1 lost
#
#    - For deep merging, you must:
#         - write custom logic with for expressions
#         - or use third-party deep merge modules
#
###############################################
```
```hcl
# If you want to merge two lists, use the concat() function instead:
locals {
  list1 = ["a", "b"]
  list2 = ["c", "d"]
  merged_list = concat(local.list1, local.list2)
}

#merged_list will be: ["a", "b", "c", "d"]

locals {
  list1 = [
    { key = "luke", value = "jedi" },
    { key = "yoda", value = "jedi" }
  ]

  list2 = [
    { key = "darth", value = "sith" },
    { key = "palpatine", value = "sith" }
  ]

  merged_list = merge({ for elem in concat(local.list1, local.list2) : elem.key => elem })
  merged_list2 = { for elem in concat(local.list1, local.list2) : elem.key => elem.value }
  merged_list_as_list = concat(local.list1, local.list2)
}

# merged_list_as_list = concat(local.list1, local.list2)
#   + name = [
#       + {
#           + key   = "luke"
#           + value = "jedi"
#         },
#       + {
#           + key   = "yoda"
#           + value = "jedi"
#         },
#       + {
#           + key   = "darth"
#           + value = "sith"
#         },
#       + {
#           + key   = "palpatine"
#           + value = "sith"
#         },
#     ]

# merged_list2 = { for elem in concat(local.list1, local.list2) : elem.key => elem.value }
# + name = {
#       + darth     = "sith"
#       + luke      = "jedi"
#       + palpatine = "sith"
#       + yoda      = "jedi"
#     }


# merged_list = merge({ for elem in concat(local.list1, local.list2) : elem.key => elem })
#  + name = {
#       + darth     = {
#           + key   = "darth"
#           + value = "sith"
#         }
#       + luke      = {
#           + key   = "luke"
#           + value = "jedi"
#         }
#       + palpatine = {
#           + key   = "palpatine"
#           + value = "sith"
#         }
#       + yoda      = {
#           + key   = "yoda"
#           + value = "jedi"
#         }
#     }
```
```hcl
locals {
  list_of_lists = [
    [
      { key = "luke", value = "jedi" },
      { key = "yoda", value = "jedi" }
    ],
    [
      { key = "darth", value = "sith" },
      { key = "palpatine", value = "sith" }
    ]
  ]

  merged_list = flatten(local.list_of_lists)
}

output "name" {
  value = local.merged_list
}

#  + name = [
#       + {
#           + key   = "luke"
#           + value = "jedi"
#         },
#       + {
#           + key   = "yoda"
#           + value = "jedi"
#         },
#       + {
#           + key   = "darth"
#           + value = "sith"
#         },
#       + {
#           + key   = "palpatine"
#           + value = "sith"
#         },
#     ]

#Nested list
variable "nested_list"{
  type = list(list(string))
  default = [ [ "mahin","raza" ], [ "mahin","raza" ], ["sameer","khan"], ["first_name","last_name"]]
}

output "opt" {
  value = toset(flatten(var.nested_list))
}
```
```hcl
# ----------------------------------------------------------
# Testing with Terraform Console
      terraform console
      > flatten([["luke","yoda"], ["darth"]])

# ----------------------------------------------------------
# Basic Examples

#  Example A: Simple nested list
      flatten([["luke","yoda"], ["darth"]])
#      → ["luke","yoda","darth"]

#  Example B: Includes empty list
      flatten([["luke"], [], ["darth"]])
#      → ["luke","darth"]

#  Example C: Deeply-nested lists
      flatten([[["luke"],[]],["darth"]])
#      → ["luke","darth"]

#  Example D: Maps are NOT flattened
      flatten([["luke"], {role="jedi"}])
#      → ["luke", {role="jedi"}]

# ----------------------------------------------------------
# Using flatten() on Variables

   variable "list_of_characters" {
     type = list(list(string))
    default = [["luke","yoda"], ["darth","palpantine"]]
   }

   flatten(var.list_of_characters)

# ----------------------------------------------------------
# Real Use Case — Preparing data for for_each

#   When data is nested (e.g., VPC → subnets), flatten()
#   helps convert nested structures into a single flat list.

   locals {
     network_subnets = flatten([
       for net_key, net in var.networks : [
         for sub_key, sub in net.subnets : {
           network_key = net_key
           subnet_key  = sub_key
           cidr_block  = sub.cidr_block
         }
       ]
     ])
   }

   resource "aws_subnet" "example" {
     for_each = {
       for s in local.network_subnets :
       "${s.network_key}.${s.subnet_key}" => s
     }

     cidr_block = each.value.cidr_block
   }

# ----------------------------------------------------------
# flatten() + for expressions

   variable "nested_map" {
     default = {
       "group:jedi"     = ["luke","yoda"]
       "group:sith"     = ["darth","palpantine"]
       "group:everyone" = ["luke","darth","c3po","r2d2"]
     }
   }

   locals {
     chars = flatten([
       for _, list in var.nested_map : list
     ])
   }

   output "distinct_chars" {
     value = distinct(local.chars)
   }

# ----------------------------------------------------------
# Key Points

   ✓ flatten() converts nested lists → single list
   ✓ Works recursively on lists
   ✗ Does NOT flatten maps or objects
   ✓ Essential for preparing data for for_each
   ✓ Often used with for expressions, concat(), distinct()

```
```hcl
variable "networks" {
  type = map(object({
    cidr_block = string
    subnets    = map(object({ cidr_block = string }))
  }))
  default = {
    "private" = {
      cidr_block = "192.168.1.0/24"
      subnets = {
        "sql1" = {
          cidr_block = "192.168.1.0/25"
        }
        "cosmos1" = {
          cidr_block = "192.168.1.128/25"
        }
      }
    },
    "public" = {
      cidr_block = "192.168.2.0/24"
      subnets = {
        "app1" = {
          cidr_block = "192.168.2.0/28"
        }
        "app2" = {
          cidr_block = "192.168.2.16/28"
        }
      }
    }
  }
}

resource "aws_vpc" "example" {
  for_each = var.networks

  cidr_block = each.value.cidr_block
}

locals {
  network_subnets = flatten([
    for network_key, network in var.networks : [
      for subnet_key, subnet in network.subnets : {
        network_key = network_key
        subnet_key  = subnet_key
        network_id  = aws_vpc.example[network_key].id
        cidr_block  = subnet.cidr_block
      }
    ]
  ])
}

resource "aws_subnet" "example" {
  for_each = {
    for subnet in local.network_subnets : "${subnet.network_key}.${subnet.subnet_key}" => subnet
  }

  vpc_id            = each.value.network_id
  availability_zone = each.value.subnet_key
  cidr_block        = each.value.cidr_block
}
```
```hcl
$ terraform.exe console
> flatten([[["luke", "yoda"], []], ["darth"], {key1 = "jedi", key2 = "sith"} ])  
[
  "luke",
  "yoda",
  "darth",
  {
    "key1" = "jedi"
    "key2" = "sith"
  },
]
>
```
```hcl
variable "nested_map" {
  type = map(any)
  default = {
    "group:jedi" = [
      "luke",
      "yoda"
    ],
    "group:sith" = [
      "darth",
      "palpantine"
    ],
    "group:everyone" = [
      "luke",
      "darth",
      "c3po",
      "r2d2"
    ],
  }
}

locals {
  flattened_map_group_name = flatten([
    for group, characters in var.nested_map : [
      group
    ]
  ])
  flattened_map_characters = flatten(
    [
        for group, char in var.nested_map: char
    ]
  )
}

output "result" {
  value = distinct(local.flattened_map_group_name)
}
output "result1" {
  value = local.flattened_map_characters
}
```
```hcl
variable "instance_types" {
  default = {
    dev  = "t2.micro"
    prod = "t3.large"
  }
}
resource "aws_instance" "this" {
  instance_type = lookup(var.instance_types, "qa", "t2.small")
}
# → qa missing → returns “t2.small”


#Feature flags / conditionally create resource
locals {
  feature_flags = {
    enable_ec2 = true
    enable_s3  = false
  }
}
resource "aws_instance" "this" {
  count = lookup(local.feature_flags, "enable_ec2", false) ? 1 : 0
}

#Optional parameter
variable "sg_settings" {
  default = {
    name = "example-sg"
  }
}
resource "aws_security_group" "example" {
  name        = lookup(var.sg_settings, "name", "default-sg")
  description = lookup(var.sg_settings, "description", null)
}


#lookup() with Nested Map
locals {
  my_nested_map = {
    a = { param1 = 1, param2 = 2 }
    b = { param1 = 3, param2 = 4 }
  }
  result = lookup(
            lookup(local.my_nested_map, "a"),
             "param1",
              0
           )
}

#lookup() with Terraform Resources
variable "Security_Groups" {
 type = list(object(
   {
     name        = string
     description = string
     ingress = optional(list(object({
       from_port   = number
       to_port     = number
       protocol    = string
       cidr_blocks = list(string)
     })), [
       {
         from_port   = 8080
         to_port     = 8080
         protocol    = "tcp"
         cidr_blocks = ["10.0.0.0/8"]
     }])
 }))
 default = [
   {
     name        = "SecurityGroups-Web"
     description = "Security group for web servers"
     ingress = [
       {
         from_port   = 80
         to_port     = 80
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
       },
       {
         from_port   = 443
         to_port     = 443
         protocol    = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
       }
     ]
   },
   {
     name        = "SecurityGroups-App"
     description = "Security group for application servers"
     ingress = [
       {
         from_port   = 8081
         to_port     = 8081
         protocol    = "tcp"
         cidr_blocks = ["10.0.0.0/8"]
     }]
 }]
}

locals {
 SecurityGroups_description = lookup(
   [for sg in var.Security_Groups : sg if sg.name == "SecurityGroups-App"][0],
   "description",
 "")
}

output "my_value_output" {
 value = local.SecurityGroups_description
}

$ terraform plan
Changes to Outputs:
  + my_value_output = "Security group for application servers"
You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.


#lookup() — Missing Key Example
locals {
  my_nested_map = {
    a = { param1 = 1 }
  }
  result = lookup(
              lookup(local.my_nested_map, "a"),
              "non_existent_param",
              0
           )
}
# → returns default 0

#lookup() vs element()
lookup(map, key, default) # map lookup with fallback
element(list, index)      # list index access, NO fallback

element( ["a","b"], 5 ) #ERROR
lookup( {a="x"}, "z", "default" ) #"default"
```
```hcl
#Element functio used to select a item from the sequence using index.
#element(<collection>,<index>)
# The index has to be zero or greater (with a max value of 9223372036854775807, which you are unlikely to reach).
#list[0] == element(list,0)
###############################################
# Terraform element() — Full Explanation Box #
###############################################

# -------------------------------
# WHAT element() DOES
# -------------------------------
# The element() function returns a single value from a LIST or TUPLE.
# Syntax:
#     element(list, index)
#
# - 'list'  → must be list() or tuple()
# - 'index' → zero-based
#
# SPECIAL BEHAVIOR:
# If the index is OUT OF RANGE → Terraform does MODULO WRAP-AROUND.
# Example: element(["a","b","c"], 5) → "c" because 5 % 3 = 2
#
# element() DOES NOT work with:
# - sets (unordered)
# - maps (key/value)
# Convert sets to lists → tolist(var.myset)

# -------------------------------
# LIST, TUPLE, SET THEORY
# -------------------------------
# LIST:
# - Ordered
# - All elements same type
# Example: ["apple", "banana", "cherry"]
#
# TUPLE:
# - Ordered
# - Can contain mixed types
# Example: ["hello", 10, true]
#
# SET:
# - Unordered
# - Unique values only
# - Must convert to list to use element()
# Example: element(tolist(var.myset), 1)

# NOTE:
# Literal [1,2,3] is a TUPLE by default.
# Use tolist([1,2,3]) to ensure it becomes LIST.

# -------------------------------
# BASIC EXAMPLES
# -------------------------------
# Normal in-range access:
# element(["a","b","c"], 1) → "b"
#
# Out-of-range (wrap-around):
# element(["a","b","c"], 5) → "c" (5 % 3 = 2)

# -------------------------------
# REAL-WORLD USE CASES
# -------------------------------
# 1. Round-robin subnet distribution
subnet_id = element(var.subnets, count.index)
# Useful when count > number of subnets → wraps cycles

# 2. Round-robin AZ assignment
az = element(var.azs, count.index)

# 3. Cycle SSH keys / tags / any repeated values
public_key = element(var.ssh_keys, count.index)

# 4. Pick first item from a dynamic list of resources
output "first_vm" {
  value = element(azurerm_virtual_machine.vm.*.name, 0)
}

# -------------------------------
# WHEN NOT TO USE element()
# -------------------------------
# If you want strict indexing WITHOUT wrap-around,
# use direct index syntax instead:
# var.list[2]
#
# Avoid element() with sets → order not guaranteed.

# -------------------------------
# INTERNAL TYPE CHECK BEHAVIOR
# -------------------------------
# terraform console:
# type([1,2,3])
# → tuple([number, number, number])
#
# type(tolist([1,2,3]))
# → list(number)

###############################################
# SUMMARY
# element() = safe, cyclical index function for lists/tuples
###############################################


$ terraform console
> element(["first", "second", "third"], 0)
"first"
>
> element(tolist(["first", "second", "third"]), 0)
"first"
>
> element(toset(["first", "second", "third"]), 0)
Error: Error in function call
Call to function "element" failed: cannot read elements from set of string.


$ terraform console
> element(["first", "second", "third"], 0)
"first"
> element(["first", "second", "third"], 1)
"second"
> element(["first", "second", "third"], 2)
"third"

$ terraform console
> ["first", "second", "third"][0]
"first"
> ["first", "second", "third"][1]
"second"
> ["first", "second", "third"][2]
"third"
```
```hcl
###########################################################
# Why Use Terraform element() Instead of list[index]?     #
###########################################################

# ---------------------------------------------------------
# PRIMARY REASON: AUTO INDEX WRAP-AROUND (MODULO LOGIC)
# ---------------------------------------------------------
# element() has one unique and powerful feature:
#   → If index > length(list), Terraform automatically wraps
#     the index using MODULO arithmetic.
#
# This means:
#   element(list, index) = list[index % length(list)]
#
# Example:
#   list length = 3 → valid indexes are 0,1,2
#
# Index: 3 → 3 % 3 = 0 → returns element 0
# Index: 4 → 4 % 3 = 1 → returns element 1
# Index: 5 → 5 % 3 = 2 → returns element 2
#
# With element():
# ✔ No errors for large index values
# ✔ Perfect for round-robin assignments
#
# But:
# Using square brackets → list[3] = ERROR (index out of range)

# ---------------------------------------------------------
# WHY WRAPPING BEHAVIOR IS USEFUL
# ---------------------------------------------------------
# element() allows looping repeatedly through a list
# even when count.index or for_each index increases.
#
# Popular use cases:
#   - multi-AZ cycles
#   - subnet rotation
#   - cycling SSH keys / tags / disk configs
#   - repeated VM / NIC patterns
#
# Without element(), Terraform would fail for index overflow.

# ---------------------------------------------------------
# DEMONSTRATION FROM terraform console
# ---------------------------------------------------------
# Given list: ["first", "second", "third"]
#
# element(["first", "second", "third"], 0) → "first"
# element(["first", "second", "third"], 1) → "second"
# element(["first", "second", "third"], 2) → "third"
#
# Now index exceeds list length:
#
# element(["first", "second", "third"], 3)
# → 3 % 3 = 0 → "first"
#
# element(["first", "second", "third"], 4)
# → 4 % 3 = 1 → "second"
#
# element(["first", "second", "third"], 5)
# → 5 % 3 = 2 → "third"
#
# This cycle continues indefinitely.

```

```hcl
resource "aws_security_group" "web" {
 name        = "web"
 description = "Security group for web servers"
 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
   Name = "web"
 }
}

locals {
 web_sg_id = lookup(aws_security_group.web, "id", "")
}

output "my_value_output" {
 value = local.web_sg_id
}
```
```hcl
locals {
   my_nested_map = {
       a = {
           param1 = 1
           param2 = 2
       }
       b = {
           param1 = 3
           param2 = 3
       }
   }
   my_nm_lookup = lookup(lookup(local.my_nested_map, "a"), "non_existent_param", 0)
}
```
```hcl
####################################################################################################
# Terraform element() Function – Full Real-World Use Case (AWS VPC + Subnet Distribution Example) #
####################################################################################################

# -----------------------------------------------------------------------------------------------
# GOAL:
# Create a VPC and evenly spread N subnets across all availability zones of ANY AWS region.
#
# Challenge:
# - Different regions have different counts of AZs (e.g., eu-west-1 → 3 AZs, us-east-1 → 6 AZs)
# - We want to create a fixed number of subnets (e.g., 10)
# - Subnets should be evenly spread across AZs
#
# Solution:
# Use *element()* to cycle through availability zones using modulo wrapping.
# -----------------------------------------------------------------------------------------------

######################################
# VARIABLES (variables.tf)
######################################
variable "aws_region" {
  type = string
}

variable "number_of_subnets" {
  type = number
}

######################################
# VPC RESOURCE (main.tf)
######################################
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-spacelift-${var.aws_region}"
  }
}

##############################################
# QUERY ALL AZs IN THE REGION (main.tf)
##############################################
# AWS determines how many AZs exist in a region.
# This avoids hardcoding.
data "aws_availability_zones" "available" {
  state = "available"
}

##################################################################################################
# SUBNET RESOURCE (main.tf)
##################################################################################################
# count.index goes from 0 to number_of_subnets-1
# element() cycles AZs even if index > number of AZs
#
# Example:
# List of AZs in eu-west-1 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"] → length = 3
#
# Index:
#   0 → a
#   1 → b
#   2 → c
#   3 → 3 % 3 = 0 → a
#   4 → 4 % 3 = 1 → b
#   5 → 5 % 3 = 2 → c
#
# This perfectly distributes subnets across AZs.
##################################################################################################

resource "aws_subnet" "all" {
  count  = var.number_of_subnets
  vpc_id = aws_vpc.this.id

  # Produces sequential /24 blocks for each subnet
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)

  # <<< element() USE CASE HERE >>>
  # Distribute subnets across AZs
  availability_zone = element(
    data.aws_availability_zones.available.names,
    count.index
  )

  tags = {
    Name = "subnet-spacelift-${var.aws_region}-${count.index}"
  }
}

######################################
# PROVIDER CONFIG (providers.tf)
######################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

######################################
# SAMPLE VARIABLES (terraform.tfvars)
######################################
# Example 1: Region with 3 AZs
aws_region        = "eu-west-1"
number_of_subnets = 10

# Example 2: Region with 6 AZs
# aws_region        = "us-east-1"
# number_of_subnets = 10

###############################################
# HOW element() DISTRIBUTES SUBNETS
###############################################
# Example: number_of_subnets = 10
# Region: eu-west-1 (3 AZs)

# count.index: 0,1,2,3,4,5,6,7,8,9
# AZs: ["a", "b", "c"]
#
# Result:
# index → AZ
#   0   → a
#   1   → b
#   2   → c
#   3   → a
#   4   → b
#   5   → c
#   6   → a
#   7   → b
#   8   → c
#   9   → a

# This gives:
#   a: 4 subnets
#   b: 3 subnets
#   c: 3 subnets

###############################################
# WHY element() IS PERFECT HERE
###############################################
# ✔ Automatically spreads subnets across however many AZs exist  
# ✔ No need to hardcode AZ counts per region  
# ✔ No index-out-of-range errors  
# ✔ Perfect modulo cycling behavior  
# ✔ Always distributes evenly  
# ✔ Works for ANY region and ANY number of subnets  

###############################################
# OTHER REAL-WORLD USE CASES
###############################################
# You should use element() whenever you want to evenly distribute:
#
#   - EC2 instances across subnets  
#   - Workloads across availability zones  
#   - Tags or labels across multiple resources  
#   - Deployments across Kubernetes namespaces  
#   - Resources across multiple AWS regions  
#
# If you want each value used *once*, use list[index].
# If you want repeated cycling → use element().
###############################################
```


### EXPANDING ARGUMENT (…) — UNPACK LIST INTO ARGUMENTS
* Useful for merge(list_of_maps...)
```hcl
locals {
  list_of_maps = [
    { a = "a", d = "d" },
    { b = "b", e = "e" },
    { c = "c", f = "f" }
  ]

  expanding_map = merge(local.list_of_maps...)  # Unpacks list
}

  <!-- + name = {
      + a = "a"
      + b = "b"
      + c = "c"
      + d = "d"
      + e = "e"
      + f = "f"
    } -->
```

---

# 4. **ENCODING FUNCTIONS**

| Function         | Example                    | Result       |
| ---------------- | -------------------------- | ------------ |
| `jsonencode()`   | `jsonencode({a=1})`        | `'{"a":1}'`  |
| `jsondecode()`   | `jsondecode("{\"a\":1}")`  | `{a=1}`      |
| `yamlencode()`   | `yamlencode({a=1})`        | `"a: 1"`     |
| `yamldecode()`   | `yamldecode("a: 1")`       | `{a=1}`      |
| `base64encode()` | `base64encode("hello")`    | `"aGVsbG8="` |
| `base64decode()` | `base64decode("aGVsbG8=")` | `"hello"`    |

```hcl
#jsondecode(string) — PARSE JSON STRING INTO MAP/LIST
locals {
  json_data = jsondecode("{\"hello\":\"world\"}")
}

#jsonencode(value) — CONVERT VALUE TO JSON STRING
locals {
  json_string = jsonencode({ hello = "world" })
}

#yamldecode(string) — PARSE YAML TO MAP/LIST
locals {
  yaml_data = yamldecode("hello: world")
}

#yamlencode(value) — CONVERT VALUE TO YAML STRING
locals {
  yaml_string = yamlencode({ a = "b", c = "d" })
}
---

# ⭐ 5. **FILESYSTEM FUNCTIONS**

| Function       | Example                          | Result              |
| -------------- | -------------------------------- | ------------------- |
| `file()`       | `file("data.txt")`               | contents of file    |
| `filebase64()` | `filebase64("bin.zip")`          | base64 encoded data |
| `filemd5()`    | `filemd5("file.txt")`            | `"md5hash"`         |
| `filesha1()`   | `filesha1("file.txt")`           | SHA1                |
| `fileset()`    | `fileset("./configs", "*.json")` | list of files       |
| `fileexist()`  |                                  |                     |
| `adspath()`    |                                  |                     |
| `templatefile()`|                                  |                     |

```hcl
#file(path) — READ FILE CONTENT AS STRING
locals {
  file_content = file("./a_file.txt")
}

#templatefile(path, vars) — APPLY VARIABLES TO TEMPLATE
locals {
  template_output = templatefile(
    "./file.yaml",
    { change_me = "awesome_value" }
  )
}
```
---
```yaml
---
- name:
  hosts:
  tasks:
  - name: Install
    yum:
      name: ${change_me}
      state: present
```
```hcl
locals {
   a_template_file = templatefile("./file.yaml", { "change_me" : "httpd" })
}

output "a_template_file" {
 value = local.a_template_file
}
```

---

# ⭐ 6. **DATE & TIME FUNCTIONS**

| Function      | Example                      | Result                   |
| ------------- | ---------------------------- | ------------------------ |
| `timestamp()` | `timestamp()`                | `"2025-01-30T06:02:15Z"` |
| `formatdate()`|                              |                          |
| `timeadd()`   | `timeadd(timestamp(), "1h")` | timestamp + 1 hour       |
| `uuid()`      | `uuid()`                     | random UUID              |

---

# ⭐ 7. **CRYPTO & HASH FUNCTIONS**

| Function   | Example                | Result                               |
| ---------- | ---------------------- | ------------------------------------ |
| `md5()`    | `md5("hello")`         | `"5d41402abc4b2a76b9719d911017c592"` |
| `sha1()`   | `sha1("hello")`        | SHA1 hash                            |
| `sha256()` | `sha256("hello")`      | SHA256 hash                          |
| `bcrypt()` | `bcrypt("mypassword")` | bcrypt hash                          |

---

# ⭐ 8. **IP NETWORK FUNCTIONS**

| Function        | Example                           | Result            |
| --------------- | --------------------------------- | ----------------- |
| `cidrhost()`    | `cidrhost("10.0.0.0/16", 5)`      | `"10.0.0.5"`      |
| `cidrsubnet()`  | `cidrsubnet("10.0.0.0/16", 4, 2)` | `"10.0.32.0/20"`  |
| `cidrnetmask()` | `cidrnetmask("10.0.0.0/24")`      | `"255.255.255.0"` |
| `cidr2mask()`   | `cidr2mask(24)`                   | `"255.255.255.0"` |

---

# ⭐ 9. **TYPE CONVERSION FUNCTIONS**

| Function     | Example                | Result      |
| ------------ | ---------------------- | ----------- |
| `tostring()` | `tostring(123)`        | `"123"`     |
| `tonumber()` | `tonumber("123")`      | `123`       |
| `tolist()`   | `tolist({a=1,b=2})`    | list        |
| `tomap()`    | `tomap([1,2])`         | map         |
| `toset()`    | `toset(["a","b","b"])` | `["a","b"]` |
| `tomap()`    | `tomap({a=1})`         | map         |
| `tobool()`   |                        |             |

```hcl
# tonumber() → converts string → number
# tostring() → converts number/bool/null → string
# tobool()   → converts "true"/"false"/bool/null → bool
# tolist()   → converts set → list
# toset()    → converts list → set
# tomap()    → converts compatible structures → map
#
# NOTE: Not used frequently but helpful when mixing types.

locals {
  num1 = tonumber("5")
  str1 = tostring(true)
  bool1 = tobool("true")
  list1 = tolist(["a", "b"])
  set1  = toset(["a", "b", "b"])
}
```

---

# ⭐ 10. **STRUCTURAL FUNCTIONS (MAP/OBJECT/LIST PROCESSING)**

| Function            | Example                   | Result      |
| ------------------- | ------------------------- | ----------- |
| `coalesce()`        | `coalesce("", "abc")`     | `"abc"`     |
| `coalescelist()`    | `coalescelist([], ["a"])` | `["a"]`     |
| `compact()`         | `compact(["a", "", "b"])` | `["a","b"]` |
| `zipmap()`          | `zipmap(["a"], [1])`      | `{a=1}`     |
| `setintersection()` | intersection              | set         |
| `setunion()`        | union                     | set         |

---

# ⭐ 11. **DYNAMIC / EXPERIMENTAL FUNCTIONS**

| Function         | Example                      |
| ---------------- | ---------------------------- |
| `dynamic` blocks | create dynamic nested blocks |

---

# ⭐ 12. **STATE/RUNTIME FUNCTIONS**

| Function         | Example                 | Result      |
| ---------------- | ----------------------- | ----------- |
| `path.module`    | `${path.module}`        | module path |
| `path.root`      | root path               |             |
| `try()`          | `try(var.a, "default")` | fallback    |
| `can()`          | `can(var.a.b)`          | true/false  |
| `nonsensitive()` | remove sensitive flag   |             |
| `sensitive()`    | mark sensitive          |             |

```hcl
#try(value, fallback) — IF value invalid → use fallback
locals {
  map_var = { test = "this" }
  try1    = try(local.map_var.test2, "fallback")
}



variable "a" {
  type = any

  validation {
    condition     = can(tonumber(var.a))
    error_message = format("This is not a number: %v", var.a)
  }

  default = "string"
}
```
```hcl
############################################################
# TERRAFORM FILE PATHS — THEORY + PRACTICAL EXAMPLES
############################################################
#
# Terraform provides 3 important path functions:
#
#   path.module  → Path of the module where THIS code is written
#   path.root    → Path of the ROOT module (top-level .tf folder)
#   path.cwd     → Current working directory where terraform was executed
#
# These help when:
# - Reading/writing files
# - Passing file references into modules
# - Dynamically building file paths
# - Debugging module structure
#
############################################################



############################################################
# 1. path.module — Path of the current MODULE
############################################################
#
# - Always refers to the directory containing the .tf file
#   where this expression appears.
# - Works inside child modules.
# - Safe for READ operations only (e.g., file(), templatefile()).
# - NOT SAFE for WRITE operations → may cause race conditions.
#
# Example project:
#
# my_terraform_project/
#   main.tf
#   modules/
#     web_server/
#       main.tf
#       outputs.tf
#
# If outputs.tf contains:
#
output "module_path" {
  value = path.module
}
#
# terraform apply (run from root directory) → prints:
# /path/to/my_terraform_project/modules/web_server
#
############################################################



############################################################
# 2. path.root — Path of the ROOT module directory
############################################################
#
# - Always refers to the top-level project folder.
# - Same regardless of which module you are inside.
# - Best choice for generating stable root-relative paths.
#
# Example:
#
# my_terraform_project/
#   outputs.tf
#
# outputs.tf:
output "root_path" {
  value = path.root
}
#
# terraform apply → prints:
# /path/to/my_terraform_project
#
############################################################



############################################################
# 3. path.cwd — Current Working Directory
############################################################
#
# - The directory where the terraform CLI was executed.
# - NOT always the root module path.
# - Can change based on:
#     - Using `terraform -chdir=...`
#     - Running Terraform from a subfolder
#     - Different machine folder layout
#
# WARNING:
#   Using path.cwd directly inside resource arguments can
#   cause constant diffs because absolute OS paths change.
#
output "cwd" {
  value = path.cwd
}
#
# terraform apply (run at project root) →
# /path/to/my_terraform_project
#
# RUN FROM SUBDIRECTORY:
#   cd modules/web_server
#   terraform apply
# Output:
# /path/to/my_terraform_project/modules/web_server
#
############################################################



############################################################
# SUMMARY — When to Use What?
############################################################
#
# path.module → Use inside modules to reference files inside THAT module
#               (templatefile, file, data reads)
#
# path.root   → Use for stable project-root-relative paths
#               (shared templates, common scripts)
#
# path.cwd    → Use only when you truly need the working directory
#               (special CI/CD cases, custom wrappers)
#
############################################################
```

---

# ⭐ 13. **LANGUAGE META FUNCTIONS**

| Function              | Example             | Result           |
| --------------------- | ------------------- | ---------------- |
| `terraform.workspace` | `"default"`         | active workspace |
| `var.*`               | variable access     |                  |
| `local.*`             | locals              |                  |
| `depends_on`          | resource dependency |                  |

---

# ⭐ 14. **UTILITY FUNCTIONS**

| Function   | Example             | Result |
| ---------- | ------------------- | ------ |
| `uuidv5()` | UUID v5             |        |
| `merge()`  | merge multiple maps |        |


---

### TEST FUNCTIONS EASILY USING "terraform console"
```hcl
# Example:
#   terraform console
#   > max(1, 3, 5)
#   5
```

---

### CUSTOM FUNCTIONS?
    * Terraform does NOT support user-defined custom functions.
    * Terraform allows "provider-defined" functions (new feature).

---

### Expressions

```hcl
# Expressions are “logic + evaluation” inside Terraform.
# They appear everywhere: variables, resources, outputs, locals, etc.

#########################################################
# 1. OPERATORS
#########################################################

# -------- Arithmetic Operators (numbers only) --------
# + , - , * , / , %
# Example:
output "arithmetic_example" {
  value = 10 * 2 + (30 / 3)       # => 30
}

# % operator → remainder
output "mod_example" {
  value = 10 % 3                  # => 1
}

# -X → negative value
output "negative_example" {
  value = -5                      # => -5
}


# -------- Equality Operators (all types) --------
# == , !=
output "equality_example" {
  value = ("mahin" == "mahin")    # => true
}

# -------- Comparison Operators (numbers only) --------
# < , > , <= , >=
output "comparison_example" {
  value = (10 > 3)                # => true
}


# -------- Logical Operators (bool only) --------
# && , || , !
output "logical_example" {
  value = (true && false)         # => false
}


#########################################################
# 2. CONDITIONAL EXPRESSIONS
# Syntax:
#    condition ? value_if_true : value_if_false
#########################################################

variable "is_dev" {
  type    = bool
  default = true
}

# If is_dev = true → dev-bucket
# Else → prod-bucket
output "conditional_example" {
  value = var.is_dev ? "dev-bucket" : "prod-bucket"
}


#########################################################
# 3. SPLAT EXPRESSIONS
# Used to extract values from list of objects.
#########################################################

# Example list of objects
variable "users" {
  default = [
    { name = "Arthur", test = true },
    { name = "Martha", test = true }
  ]
}

# FULL "for" expression
output "for_expression_example" {
  value = [for u in var.users : u.name]     # => ["Arthur", "Martha"]
}

# SPLAT expression (shorter version)
output "splat_expression_example" {
  value = var.users[*].name                 # => ["Arthur", "Martha"]
}

# Note:
# Works only on lists, sets, tuples.
# If applied to a single object → Terraform wraps into a tuple.


#########################################################
# 4. CONSTRAINTS (Type + Version)
#########################################################

# ---- TYPE CONSTRAINTS ----
# Used in variables and outputs.

variable "my_string" {
  type = string       # must be "text"
}

variable "my_list" {
  type = list(number) # must be list of numbers: [1,2,3]
}

variable "my_map" {
  type = map(string)  # must be { key = "value" }
}

# ---- VERSION CONSTRAINTS ----
# Used in provider or module blocks.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"   # version constraints example
    }
  }
}

```

---

### Loops (Meta arguments)

```hcl
###############################################################
# TERRAFORM LOOPS — COUNT, FOR_EACH, FOR  
# Loops help Terraform create multiple resources WITHOUT repeating code.
# There are 3 loop mechanisms:
#   1️⃣ count      (primitive, index-based)
#   2️⃣ for_each   (flexible, map/set-based)
#   3️⃣ for        (transforming lists/maps)
###############################################################



###############################################################
# 1️⃣ COUNT — PRIMITIVE LOOP (works with numbers only)
###############################################################

# THEORY:
# - Takes a number → creates that many resource instances.
# - Terraform assigns each instance an INDEX (0,1,2,...).
# - Good for identical resources.
# - BAD for distinct values (use for_each instead).

resource "aws_s3_bucket" "demo" {
  count = 10   # creates 10 buckets
}

# Accessing the 5th bucket’s ID:
# Index starts at 0 → 5th means index 4
output "fifth_bucket_id" {
  value = aws_s3_bucket.demo[4].id
}



###############################################################
# 2️⃣ FOR_EACH — ADVANCED LOOP (works with map or set)
###############################################################

# THEORY:
# - Best loop for UNIQUE resources (different names, AMIs, sizes).
# - Works with map or set(string).
# - Access inside with:
#      each.key   → map key
#      each.value → map value

###############################################################
# 2A. For_each with simple map
###############################################################

variable "simple_map" {
  default = {
    test1 = "value1"
    test2 = "value2"
  }
}

resource "example_resource" "demo" {
  for_each = var.simple_map

  name  = each.key
  value = each.value
}



###############################################################
# 2B. For_each with MAP OF OBJECTS (MOST POWERFUL)
###############################################################

# THEORY:
# - Allows creating resources with different parameters.
# - BEST PRACTICE for EC2, subnets, disks, IAM, etc.

variable "my_instances" {
  default = {
    instance_1 = {
      ami  = "ami-00124569584abc"
      type = "t2.micro"
    },
    instance_2 = {
      ami  = "ami-987654321xyzab"
      type = "t2.large"
    }
  }
}

resource "aws_instance" "demo" {
  for_each = var.my_instances

  ami           = each.value.ami
  instance_type = each.value.type
}

# ADDING NEW INSTANCES?
# → Only update .tfvars
# → No need to touch resource block = SUPER CLEAN



###############################################################
# 3️⃣ FOR EXPRESSIONS — TRANSFORM COLLECTIONS
###############################################################

# THEORY:
# - Used to iterate through lists or maps.
# - Can transform values.
# - Can FILTER values using "if".
# - Output type depends on brackets:
#       [ ]  → list
#       { }  → map

variable "word_list" {
  default = [
    "Critical\n",
    "failure\n",
    "teapot\n",
    "broken\n"
  ]
}

###############################################################
# 3A. For Expression (cleaning newline characters)
###############################################################

output "cleaned_words" {
  value = [for w in var.word_list : chomp(w)]
  # RESULT → ["Critical", "failure", "teapot", "broken"]
}


###############################################################
# 3B. For Expression with filtering
###############################################################

output "filtered_capitalized" {
  value = [
    for w in var.word_list :
    upper(w)               # transform
    if w != "teapot"       # filter out "teapot"
  ]
  # RESULT → ["CRITICAL", "FAILURE", "BROKEN"]
}


###############################################################
# 3C. For Expression producing a MAP
###############################################################

output "map_of_words" {
  value = {
    for w in var.word_list :
    w => length(w)
  }
  # RESULT something like:
  # {
  #   "Critical\n" = 9,
  #   "failure\n"  = 8,
  #   ...
  # }
}

```
