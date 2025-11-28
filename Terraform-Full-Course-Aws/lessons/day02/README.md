# Day 2: Terraform Provider

## Topics Covered
- Terraform Providers
- Provider version vs Terraform core version
- Why version matters
- Version constraints
- Operators for versions

## Key Learning Points

### What are Terraform Providers?
Providers are plugins that allow Terraform to interact with cloud platforms, SaaS providers, and other APIs. For AWS, we use the `hashicorp/aws` provider.
Responcible to translate a HCL code into to api calls.

Terraform not only works with cloud providers it can also work with docker, k8s, promethius, grafana, datadog etc.

version -->2 type --> terrform, provider

### Provider vs Terraform Core Version
- **Terraform Core**: The main Terraform binary that parses configuration and manages state
- **Provider Version**: Individual plugins that communicate with specific APIs (AWS, Azure, Google Cloud, etc.)
- They have independent versioning and release cycles

### Why Version Matters
- **Compatibility**: Ensure provider works with your Terraform version
- **Stability**: Pin to specific versions to avoid breaking changes
- **Features**: New provider versions add support for new AWS services
- **Bug Fixes**: Updates often include important security and bug fixes
- **Reproducibility**: Same versions ensure consistent behavior across environments

---

### **Why Terraform Version Is Important**
  * Terraform language (HCL) changes between versions
  * New features appear, old features get deprecated
  * State file format changes → older versions may break
  * Different versions produce **different plans** → inconsistent infra.
  * Teams must use the same version for predictable results
  * CI/CD pipelines require version lock to avoid unexpected failures.

  ```bash
  #terrform binary bersion --->
  $ terraform -version
  Terraform v1.12.2
  on windows_amd64
  + provider registry.terraform.io/hashicorp/aws v4.67.0

  Your version of Terraform is out of date! The latest version
  is 1.14.0. You can update by downloading from https://developer.hashicorp.com/terraform/install

  #And terrform config have differnet version
  $ terraform init
  Initializing the backend...
  ╷
  │ Error: Unsupported Terraform Core version
  │
  │   on main.tf line 9, in terraform:
  │    9:   required_version = "1.14.0"
  │
  │ This configuration does not support Terraform version 1.12.2. To proceed, either choose another supported Terraform version or      
  │ update this version constraint. Version constraints are normally set for good reason, so updating the constraint may lead to other  
  │ errors or unexpected behavior.
  ╵
  ```

### **Why Provider Version Is Important**
  * Providers (AWS, Azure, GCP) change **very frequently**
  * New API changes may break old Terraform code
  * Arguments/resources get deprecated → plan/apply errors
  * Upgrading providers can recreate resources unexpectedly
  * Unpinned versions cause Terraform to install latest → dangerous
  * Provider version affects state and resource behavior

### **Why Version Pinning Is Necessary**
  * Ensures predictable, stable, reproducible infrastructure
  * Prevents accidental upgrades and breaking changes
  * Makes all environments (dev, test, prod) behave the same
  * Allows safe testing before upgrades
  * Avoids team inconsistency and unexpected resource recreation.

### **Check What Is Outdated**
  Run:
  ```
  terraform version
  ```
  Then check providers:
  ```
  terraform providers
  ```
  To see upgrade suggestions:
  ```
  terraform init -upgrade
  ```
  This will show which providers are outdated.

### ** Upgrade Terraform Version (CLI)**
* Step 1: Update the version in your code
  In your `.tf` file:
  ```hcl
  terraform {
    required_version = ">= 1.8.0"
  }
  ```

* Step 2: Download the new Terraform binary
  Methods:
  Option A: Manual download
    [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
  Option B: Using Homebrew (macOS)
    ```
    brew upgrade terraform
    ```
  Option C: Using Chocolatey (Windows)
    ```
    choco upgrade terraform
    ```
  Option D: Using Scoop (Windows)
    ```
    scoop update terraform
    ```

* Step 3: Verify
  ```
  terraform version
  ```

### **Upgrade Provider Version (AWS, Azure, GCP, etc.)**
* Step 1: Update version in required_providers block
  Example for AWS:
  ```hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.35"
      }
    }
  }
  ```
* Step 2: Run upgrade command
  ```
  terraform init -upgrade
  ```
  This forces Terraform to download the latest allowed provider version.

### **Validate the Configuration**
  Run:
  ```
  terraform validate
  ```
  Then:
  ```
  terraform plan
  ```
  Check for:
  ✔ breaking changes
  ✔ deprecations
  ✔ resource recreation
  ✔ errors

### **Apply the Changes (If Safe)**
  Once you confirm the plan is correct:
  ```
  terraform apply
  ```

### **How to Upgrade Providers Safely (Best Practices)**
  * Always test upgrades in DEV first
  * Read the provider release notes
  * Avoid huge jumps (example: AWS 3.x → 5.x)
  * Use version constraints carefully
  * After upgrade: re-check state refresh carefully
  Example safe constraint:
  ```hcl
  version = "~> 5.0"
  ```
  This allows updates 5.0 → 5.99 but blocks 6.x.

### **How to Check Why a Provider Is Outdated**
  ```
  terraform providers mirror
  terraform providers schema
  terraform lock
  ```
  You can also inspect:
  ```
  .terraform.lock.hcl
  ```
  This file stores the exact provider versions.


### Version Constraints
Use version constraints to specify acceptable provider versions:

- `= 1.2.3` - Exact version
- `>= 1.2` - Greater than or equal to
- `<= 1.2` - Less than or equal to
- `~> 1.2` - Pessimistic constraint (allow patch releases)
- `>= 1.2, < 2.0` - Range constraint

### Best Practices
1. Always specify provider versions
2. Use pessimistic constraints for stability
3. Test provider upgrades in development first
4. Document version requirements in your README
5. Use terraform providers lock command for consistency

## Configuration Examples

### Basic Provider Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Multiple Provider Versions
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
```


## Next Steps
Proceed to Day 3 to learn about creating your first AWS resources with Terraform and check task.md for your assignments.
