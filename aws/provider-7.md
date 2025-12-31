**Provider Versioning and Independence**
  * Each provider plugin is developed and released independently from Terraform Core.
  * This allows:
      * Faster updates for provider-specific fixes.
      * Support for new cloud APIs without waiting for a Terraform release.
  * You can pin versions to prevent breaking changes(**Provider Version Locking**):
    ```hcl
    terraform {
      required_version = ">= 1.12.0"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 4.0, < 5.0"
        }
      }
    }
    ```
    ```hcl
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "6.3.0"
        }
      }
    }
    ```
    * This locks the AWS provider version to 5.x (but allows patch updates).
    * Prevents breaking changes from new major versions.

<br>

* **Difference version constraints**
  ```bash
  provider "aws" {} #latest

  required_version = "2.17.0" #Exact Version Constraint

  required_version = ">= 2.17.0"

  required_version = "< 3.0.0"

  required_version = ">= 2.17.0, < 3.0.0"

  required_version = "> 1.12.0, <=1.12.5"

  #Pessimistic Constraint
  required_version = "~> 2.17.0"  #Pin PATCH version --> 2.17.0 , 2.17.1, 2.17.2 etc

  required_version = "~> 2.17" #Pin MINOR version --> 2.17.1, 2.18.0, 2.30.0 etc Not-> 3.x.x

  required_version = ">= 2.17" #Wildcard Constraint Very open → NOT recommended unless needed.
  ```

<br>

* **Provider version locking**
  * Always specify the provider version: `version = "~> 2.17.0"` or version = "2.17.0" 
  * Without it whenever your run a `terraform init` or `terraform init -upgrade` it will upgrade a provider to the most recent version it can cause:
    * If provider change something in latest pluging unintended upgrade can cause breaking of config.
  * Providers often change:
    * Resource attributes
    * Field formats
    * Required arguments
    * API behaviors
    * Data source outputs
  * It make config predictable and prevent breaking.