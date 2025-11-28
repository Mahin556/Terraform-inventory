* Open-source
* IAC tool
* Provision infra using code/config file
* Config file --> HCL(mostly),yaml,json etc
* Config file ---> State of infra
* Allow
    * Reuse
    * Version control
    * Keep it with project on github
    * Collaboration
    * State Management
* Hashicorp is the company that created a terraform.
* Support multiple provides
* Support multiple Cloud providers
* Track resources with state
* Collaborate with terraform cloud
* can write config on 
    * HCL(Hashicorp Configuration language) ---> Declarative language
    * JSON ---> applications, wide supported
* It uses `.tf` extension(config file extension).
* Scripting ---> Each instruction execute and no state management
* Delarative ---> State management, first change state and change in state(state comparision, state matching).
* **State management**
    * `terraform.tfstate`
    * It’s a JSON file that records the current state of your infrastructure.
    * It maps real-world resources (on AWS, Azure, etc.) to your Terraform configuration files.
    * Example: It remembers that "aws_instance.example" corresponds to a specific EC2 instance ID.
    * Recommended: store it remotely using a backend like:
        * AWS S3 (with DynamoDB for locking)
        * Terraform Cloud
        * GCS (Google Cloud Storage)
        * Azure Blob Storage
    * This helps multiple team members work safely on the same project.
    * Without the state file, Terraform wouldn’t know what resources already exist.
    * Never edit the state file manually.
    * Use version control for configuration, not for state files.
    * Use remote backends for collaboration.
    * Encrypt the state file if it contains secrets (e.g., resource IDs, credentials).
* Modules are reusable Terraform configurations that can be called and configured by other configurations. Most modules manage a few closely related resources from a single provider.
* The Terraform Registry makes it easy to use any provider or module. To use a provider or module from this registry, just add it to your configuration; when you run `terraform init`, Terraform will automatically download everything it needs.

* For each project use a saperate directory.

* **Purpose of the `terraform` Block**

```hcl
terraform {
  required_version = "1.12.2"
}
```


* The `terraform {}` block is a **special configuration block** in every Terraform project.
* Ensures that **team members** use the same Terraform version.
* Avoids unexpected behavior when Terraform introduces syntax or feature changes.
* It defines **global settings** for the configuration — such as:
  * Required Terraform version
  * Required provider versions
  * Backend configuration
  * CLI behavior

So this block tells Terraform **what environment and dependencies** your configuration expects.

* **`required_version`**
    * The `required_version` argument ensures that Terraform runs only if the version installed on your system matches the specified constraint.
    * It’s a **safeguard** against version mismatch problems, because different Terraform versions can behave differently or deprecate syntax.
    * In Your Example
    ```hcl
    terraform {
    required_version = "1.12.2"
    }
    ```
    * This means:
        * * Terraform **will only run** if the installed version is exactly **1.12.2**.
        * If you’re running Terraform 1.12.1 or 1.12.3 (or 1.13.x, etc.), it will fail with:
            ```
            Error: Unsupported Terraform Core version
            This configuration does not support Terraform version 1.13.0. Please use Terraform 1.12.2.
            ```


* **Commonly Used Version Constraints**
    * Instead of pinning to one exact version, you can use **operators** for flexibility:

        | Operator | Meaning                                  | Example      | Allowed Versions      |
        | -------- | ---------------------------------------- | ------------ | --------------------- |
        | `=`      | Exactly this version                     | `"=1.12.2"`  | Only 1.12.2           |
        | `!=`     | Not equal to                             | `"!=1.12.2"` | Any except 1.12.2     |
        | `>`      | Greater than                             | `">1.12.2"` | 1.12.2 above      |
        | `<`      | Less than                                | `"<1.13.0"`  | Anything below 1.13.0 |
        | `>=`     | Greater than or equal to                 | `">=1.12.2"` | 1.12.2 and higher     |
        | `<=`     | Less than or equal to                    | `"<=1.13.0"` | Up to 1.13.0          |
        | `~>`     | Compatible with (pessimistic constraint) | `"~>1.12.0"` | 1.12.x (not 1.13.x)   |

    * Example (Best Practice)
        * It’s recommended to **allow patch updates but restrict major/minor changes**, like this:
            ```hcl
            terraform {
            required_version = "~> 1.12.0"
            }
            ```
        * This means:
            * Use **any 1.12.x** version (like 1.12.1, 1.12.2, 1.12.3…)
            * But **not 1.13.x or higher**, as that might introduce breaking changes.

* **Example with Providers and Backend**
    * A complete `terraform` block often looks like this:
        ```hcl
        terraform {
        required_version = "~> 1.12.0"

        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
            }
        }

        backend "s3" {
            bucket = "my-terraform-state"
            key    = "env/dev/terraform.tfstate"
            region = "ap-south-1"
        }
        }
        ```
    * This specifies:
        * Terraform version (`1.12.x`)
        * AWS provider and its version (`5.x`)
        * Remote backend for state storage (`S3`)
