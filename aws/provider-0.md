* **How to Declare a Provider in Terraform**
You specify it in your configuration files, usually in providers.tf or main.tf:
    ```hcl
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
      region = "us-east-1"
      access_key = "..."
      secret_key = "..."
    }
    ```
    ```bash
    terraform init
    ```
    Terraform:
    * Installs the required provider plugin.
    * Locks its version in .terraform.lock.hcl (for consistent builds).
    * Verifies checksum and version.

    If you don’t mention a provider version in Terraform, it will:
    * Automatically download the latest version of the AWS provider from the Terraform Registry.
    * Save it in the .terraform folder when you run terraform init.