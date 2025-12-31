# A Terraform map variable is a key-value data structure that groups related values under a single variable, allowing structured access to configuration data.

# The following types can be used to define your map:

# map(string): The values in the map are of type “string.”
# map(number): The values in the map are of type “number” (integer or floating-point).
# map(bool): The values in the map are of type “bool” (true or false).
# map(list): The values in the map are lists (arrays) containing elements of the same type.
# map(set): The values in the map are sets containing unique elements of the same type.
# map(object({ ... })): The values in the map are objects (complex data structures) that must conform to a specific structure defined by the object’s attributes.


##############################
# Difference Between map and object in Terraform
##############################

# Summary:
# - map    : A simple key-value structure, all values must be the same type.
# - object : A structured type with specific attributes that can each have different types.

##############################
# Example 1: map (All values must be of the same type)
##############################

variable "tag_map" {
  type = map(string)
  default = {
    Name        = "web-server"
    Environment = "dev"
  }
}

##############################
# Example 2: object (Values can be different types)
##############################

variable "instance_config" {
  type = object({
    name        = string
    instance_id = number
    is_enabled  = bool
  })

  default = {
    name        = "my-instance"
    instance_id = 1
    is_enabled  = true
  }
}

##############################
# Example 3: Using tags in a resource (acts like map of strings)
##############################

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name        = "Example Instance"
    Environment = "Production"
  }
}

##############################
# Best Practice:
##############################
# - Use map(type) when keys are dynamic and all values are the same type.
# - Use object({}) when keys are fixed and types are mixed.



##############################################
# Difference Between map(string) and map(object)
##############################################

# map(string) — A map where every value must be a string.
# map(object) — A map where each value is a structured object 
#               with multiple attributes (like a schema).

##############################################
# Example 1: map(string)
##############################################

variable "simple_tags" {
  type = map(string)
  default = {
    Name        = "my-server"
    Environment = "dev"
    Owner       = "mahin"
  }
}

# Usage:
output "simple_tags" {
  value = var.simple_tags
}

##############################################
# Example 2: map(object) — complex values per key
##############################################

variable "server_configs" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    "a" = {
      cidr = "10.0.1.0/24"
      az   = "us-west-1a"
    },
    "b" = {
      cidr = "10.0.2.0/24"
      az   = "us-west-1b"
    }
  }
}

# Usage:
output "server_configs" {
  value = var.server_configs
}

# Accessing an individual value:
# var.server_configs["a"].cidr → "10.0.1.0/24"

##############################################
# Summary:
# - Use map(string) for simple key-value pairs.
# - Use map(object({})) when you need structured data for each key.




variable "example_map" {
  type = map(object({
    name = string
    enemies_destroyed = number
    badguy = bool
  }))
  default = {
    key1 = {
      name = "luke"
      enemies_destroyed = 4252
      badguy = false
    }
    key2 = {
      name = "yoda"
      enemies_destroyed = 900
      badguy = false
    }
    key3 = {
      name = "darth"
      enemies_destroyed=  20000056894
      badguy = true
    }
  }
}



variable "lightsabre_color_map" {
  type = map(list(string))
  default = {
    luke = ["green", "blue"]
    yoda = ["green"]
    darth = ["red"]
  }
}


variable "lightsabre_color_map" {
  type = map(set(string))
  default = {
    luke = ["green", "blue"]
    yoda = ["green"]
    darth = ["red"]
  }
}



###########################################
# Map Variable with Local Values Example
###########################################
# map variable with local values, generating dynamic bucket names using a for loop and local values.

# Input variable: a map of characters and how many enemies they destroyed
variable "enemies_map" {
  type = map(number)
  default = {
    luke  = 4252
    yoda  = 900
    darth = 20000056894
  }
}

# Local values: create bucket names dynamically based on the character names
locals {
  bucket_names = {
    for name, destroyed in var.enemies_map :
    name => "${name}-bucket"
  }
}

# Use the local map to create multiple S3 buckets
resource "aws_s3_bucket" "buckets" {
  for_each = local.bucket_names

  bucket = each.value
#   acl    = "private"

  tags = {
    Owner = each.key
    Name  = each.value
  }
}

# Output the generated bucket names
output "bucket_names" {
  value = local.bucket_names
}


##########################################
# Convert List to Map using for loop
##########################################

locals {
  characters        = ["luke", "yoda", "darth"]
  enemies_destroyed = [4252, 900, 20000056894]

  # Convert lists to a map
  enemies_map = {
    for index, character in local.characters :
    character => local.enemies_destroyed[index]
  }
}

output "enemies_map" {
  value = local.enemies_map
}

##########################################
# Convert List to Map using for loop
##########################################

locals {
  characters        = ["luke", "yoda", "darth"]
  enemies_destroyed = [4252, 900, 20000056894]

  # Convert lists to a map
  enemies_map = {
    for index, character in local.characters :
    character => local.enemies_destroyed[index]
  }
}

output "enemies_map" {
  value = local.enemies_map
}


##########################################
# Flatten a Map to a List using flatten()
##########################################

locals {
  flattened_enemies_map = flatten([
    for key, value in local.enemies_map :
    [key, value]
  ])
}

output "flattened_enemies_map" {
  value = local.flattened_enemies_map
}


##########################################
# Convert List of Objects to Map using tomap()
##########################################

locals {
  enemies_list = [
    { name = "luke",  enemies_destroyed = 4252 },
    { name = "yoda",  enemies_destroyed = 900 },
    { name = "darth", enemies_destroyed = 20000056894 },
  ]

  # Convert list of objects to map using tomap
  enemies_map_from_list = tomap({
    for char in local.enemies_list:
        char.name => char
  })
}

output "demo2" {
  value = local.enemies_map_from_list
}


##########################################
# Mixed Type Example with tomap()
##########################################

locals {
  mixed_type_example = tomap({
    a = "luke"
    b = false
  })
}

output "mixed_type_example" {
  value = local.mixed_type_example
}

###############################################
# Terraform: map() Function (Legacy & Modern)
###############################################

# --- Deprecated Usage (Terraform < 0.12) ---
# This legacy method is no longer supported in Terraform 0.12+

# variable "legacy_map" {
#   default = map("env", "prod", "region", "us-west-1")
# }

# -------------------------------------------
# ✅ Recommended: Native Map Syntax (>= 0.12)
# -------------------------------------------

# Define a map variable using native syntax
variable "example_map" {
  type = map(string)
  default = {
    env    = "production"
    region = "us-west-1"
  }
}

# Use the map in a local
locals {
  tags = {
    Name        = "example-instance"
    Environment = var.example_map["env"]
    Region      = var.example_map["region"]
  }
}

# Use the local map in a resource
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = local.tags
}

###############################################
# Notes:
# - Native maps use curly braces {}.
# - Keys must be unique.
# - You can mix variables and locals in maps.
# - Use `tomap()` or `merge()` for dynamic maps.
###############################################

/*
Best Practices:
- Always prefer native map syntax.
- Use 'merge()' to combine maps.
- Use 'tomap()' to convert compatible structures.
- Avoid using the legacy 'map()' function (removed).
*/

