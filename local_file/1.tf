terraform {
  required_version = "~>1.9.0"  
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "local" {
  # Configuration options
}

resource "local_file" "local-file-creation" {
   file_permission = "0400"
   filename = "learning.txt"
   content = "Welcome to the terraform platform "
}

resource "local_file" "bar" {
  filename = "bar.txt"
  content = "Hello Terraform re:invent 2024"
  file_permission = "0400"
} 

# Modify content of existing file
resource "leraning.txt" "example" {
  filename = "hello.txt"
  content = "Hello! Get into the habit of continuous learning and improving!"
 }