* https://registry.terraform.io/browse/providers
* https://spacelift.io/blog/terraform-aws-provider
* https://k21academy.com/terraform-iac/terraform-providers-overview/
* https://spacelift.io/blog/terraform-providers *
---
* A Terraform provider is a binary plugin that Terraform uses to interact with external APIs and service.
* Providers expose resources (things Terraform can create/manage) and data sources (things Terraform can read/query).
* It’s responsible for translating your Terraform code (HCL – HashiCorp Configuration Language) into API calls to create, update, or delete infrastructure resources.
* Provider specified in tearrform configuration code
* 100+ providers
* Not platoform specific IAC tool ---> Using porovider plugin it can work with different platforms
* Platform-specific IAC Tool/Service, such as Microsoft Azure ARM templates or Bicep (which interact with the Azure API only), CFT.
* Terraform is the “engine”, and providers are the “drivers” that know how to talk to specific cloud platforms or services (like AWS, Azure, GCP, GitHub, Docker, Kubernetes, etc.).
* Providers are plugins that define which resources can be managed and handle the API calls to create, update, and delete resources.
* Examples:
  * aws → creates EC2, S3, VPC, etc.
  * azurerm → manages Azure resources.
  * kubernetes → deploys workloads inside a cluster.
  * local → manages local files and directories.

<br>

* **How Providers Work**
  * Terraform itself doesn’t know how to talk to AWS, GCP, or other APIs.
  * When you initialize (terraform init), Terraform:
      * Downloads the provider plugin (from the Terraform Registry or third party/internally).
      * Installs it into the .terraform/plugins directory.
      * Uses it to communicate with the target infrastructure’s API.

<br>

* **Types of Providers**

  | Provider Type | Maintainer          | Description                                                                                             |
  | ------------- | ------------------- | ------------------------------------------------------------------------------------------------------- |
  | **Official**  | HashiCorp           | Fully supported and tested by HashiCorp. (e.g. `aws`, `azurerm`, `google`)                              |
  | **Verified**  | Third-party vendors | Published by tech companies like MongoDB, Datadog, or Cisco that are **HashiCorp Technology Partners**. |
  | **Community** | Open-source users   | Created by Terraform community contributors. May not always be actively maintained.                     |
  | **Custom**    | Internal            | Custom/Private Providers You can build your own using the Terraform Plugin SDK (written in Go), Useful for internal systems or unsupported APIs. |

<br>

* **How to Declare a Provider in Terraform**
  * You specify it in your configuration files, usually in providers.tf or main.tf:
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
* Terraform:
    * Installs the required provider plugin.
    * Locks its version in .terraform.lock.hcl (for consistent builds).
    * Verifies checksum and version.
* If you don’t mention a provider version in Terraform, it will:
  * Automatically download the latest version of the AWS provider from the Terraform Registry.
  * Save it in the .terraform folder when you run terraform init.

<br>

* **How Providers Work Internally**
  * Each provider is a Go-based plugin that uses the Terraform Plugin SDK.
  * During terraform init:
    * Terraform reads your configuration files.
    * Detects which providers you need (like aws, google, kubernetes, etc.).
    * Downloads them from the Terraform Registry (or local mirror/private registry).
    * Installs them inside the hidden directory .terraform/providers/.
  * During terraform plan or apply:
    * Terraform calls the provider plugin to perform API requests.
    * The provider returns the results back to Terraform, which stores them in the state file (terraform.tfstate).

<br>

* **Resources and Data Sources**
  * Each provider exposes:
  * Resources → the types of infrastructure Terraform can manage (e.g., aws_instance, azurerm_storage_account, google_compute_instance).
  * Data sources → the types of infrastructure Terraform can manage (e.g., aws_instance, azurerm_storage_account, google_compute_instance).
  * Example:
    ```hcl
    resource "aws_instance" "example" {
      ami           = data.aws_ami.ubuntu.id
      instance_type = "t2.micro"
    }

    data "aws_ami" "ubuntu" {
      most_recent = true
      owners      = ["099720109477"] # Canonical
      filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      }
    }
    ```

<br>

* **Provider Versioning and Independence**
  * Each provider is developed and released independently from Terraform Core.
  * This allows:
      * Faster updates for provider-specific fixes.
      * Support for new cloud APIs without waiting for a Terraform release.
  * You can pin versions to prevent breaking changes(**Provider Version Locking**):
    ```hcl
    terraform {
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

  version = "2.17.0" #Exact Version Constraint

  version = ">= 2.17.0"

  version = "< 3.0.0"

  version = ">= 2.17.0, < 3.0.0"

  #Pessimistic Constraint
  version = "~> 2.17.0"  #Pin PATCH version --> 2.17.0 , 2.17.1, 2.17.2 etc

  version = "~> 2.17" #Pin MINOR version --> 2.17.1, 2.18.0, 2.30.0 etc Not-> 3.x.x

  version = ">= 2.17" #Wildcard Constraint Very open → NOT recommended unless needed.
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


* **Custom Providers (for advanced users)**
  * If the provider doesn’t exist for your platform or internal API, you can build your own.
  * Written in Go using the Terraform Plugin SDK.
  * You define:
      * Schema for resources
      * CRUD functions (Create, Read, Update, Delete)
      * API client logic
  * Then you can publish it on Terraform Registry or use it privately.
  * Example guide: https://developer.hashicorp.com/terraform/plugin

<br>

* **Provider Authentication**
  * Each provider requires credentials to access APIs.
  * For example:
      * `AWS` → ~/.aws/credentials or environment variables
      * `GCP` → JSON key file via GOOGLE_APPLICATION_CREDENTIALS
      * `Azure` → Service principal or managed identity
      * `Kubernetes` → kubeconfig file

### AWS provider
* The Terraform AWS Provider is developed and maintained by HashiCorp, the same company that created Terraform.
* It uses your AWS credentials (from your profile, environment variables, or IAM role) to authenticate and authorize operations on your AWS account.
* Without the AWS provider, Terraform wouldn’t understand AWS resource types (like aws_instance, aws_s3_bucket, or aws_vpc).
* The provider acts as a translator:
  * Terraform HCL configuration → AWS API calls → Actual infrastructure on AWS
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
  region = "ap-south-1"
}
```
#### Provider Authentication
* **Shared Credential**
  ```bash
  aws configure
  aws configure --profile=<profile_name>
  ```
  * Stored in your home directory at `~/.aws/credentials` (created by AWS CLI).
    ```bash
    [default]
    aws_access_key_id = AKIAEXAMPLE
    aws_secret_access_key = abcd1234example

    [dev]
    aws_access_key_id = AKIADEV
    aws_secret_access_key = devkeyexample
    ```
  * You can tell Terraform which profile to use:
    ```hcl
    provider "aws" {
    region  = "ap-south-1"
    profile = "default"
    }
    ```
    * `profile` → references credentials from your local `~/.aws/credentials` file.
  * Config File
    * Located at `~/.aws/config`. 
      ```bash
      [default]
      region = ap-south-1
      output = json
      ```
  * Terraform uses this together with the credentials file.
  * AWS CLI Named Profile
    * You can set the profile through an environment variable:
      ```bash
      export AWS_PROFILE=dev
      ```
      * Then Terraform automatically uses it.

<br>  

* **Static Credentials in Provider Block (Not Recommended)**
* You can hardcode credentials (for testing only):
  ```hcl
  provider "aws" {
    region     = "ap-south-1"
    access_key = "your-access-key"
    secret_key = "your-secret-key"
  }
  ```
  * Not secure — don’t use this in production or version control.

* But in best practice:
  * Don’t hardcode credentials.
  * Use environment variables, profiles, or AWS CLI credentials:
    ```bash
    cat <<EOF > .aws-creds.sh
    export AWS_ACCESS_KEY_ID="your-access-key"
    export AWS_SECRET_ACCESS_KEY="your-secret-key"
    export AWS_DEFAULT_REGION="ap-south-1"
    EOF
    ```
    * Optional (if using session tokens):
      ```bash
      export AWS_SESSION_TOKEN="FwoGZXIvYXdzEXAMPLE"
      ```
      * Terraform automatically picks these values when running commands.
    ```bash
    source .aws-creds.sh
    ```
    ```bash
    echo "source ~/.aws-creds.sh" >> ~/.bashrc
    ```

<br>

* **EC2 Instance Metadata / IAM Role/Instance Profile Credentials and Region**
  * If Terraform runs inside an EC2 instance, and that instance has an IAM role attached, Terraform automatically retrieves temporary credentials from the Instance Metadata Service (IMDS) — no keys required.
  * Supports both IMDSv1 and IMDSv2.
  * Same applies for:
    * ECS tasks (using Task IAM Roles)
    * AWS Lambda (if running Terraform inside it)
    * AWS CloudShell
  * Optional provider parameter:
    ```hcl
    provider "aws" {
      ec2_metadata_service_endpoint = "http://custom-metadata-endpoint"
    }
    ```
  * Secure and automatic — no manual credential handling needed.

<br>

* **AWS SSO (Single Sign-On) / AWS Identity Center**
  * If you’ve logged in with:
    ```bash
    aws sso login --profile my-sso-profile
    ```
  * Terraform can use those cached credentials automatically:
    ```bash
    provider "aws" {
    profile = "my-sso-profile"
    }
    ```

* **Web Identity Token (OIDC / IRSA)**
  * Used in Kubernetes or GitHub Actions to assume roles via OpenID Connect (OIDC):
    ```bash
    export AWS_ROLE_ARN="arn:aws:iam::123456789012:role/TerraformRole"
    export AWS_WEB_IDENTITY_TOKEN_FILE="/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
    ```
  * Terraform assumes that role automatically.

* **External Credentials Process (Advanced)**
  * Terraform can run an external command/script to fetch credentials dynamically.
  * In your `~/.aws/config`:
    ```bash
      [profile dynamic]
      credential_process = /usr/local/bin/fetch-aws-creds
    ```
  * Terraform runs that script to retrieve credentials in JSON format.
  * Example `~/.aws/credentials` file:
    ```bash
    [profile get_external_credentials]
    credential_process = /usr/local/bin/get_external_credentials --username myuser
    ```

<br>

* **Custom Credential Helper / AWS Vault**
  * If you use tools like aws-vault or chamber, Terraform inherits credentials from your active session.
  * Example:
    ```bash
    aws-vault exec dev -- terraform apply
    ``` 

<br>

* **Container Credentials**
  * Used when Terraform runs inside AWS ECS, CodeBuild, or EKS.
  * Terraform automatically retrieves credentials via environment variables:
    * ECS:
      `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`
      `AWS_CONTAINER_CREDENTIALS_FULL_URI`
    * EKS (IRSA):
      `AWS_ROLE_ARN`
      `AWS_WEB_IDENTITY_TOKEN_FILE`
  * Ideal for containerized Terraform runs (no static keys needed).

<br>

* **Assuming IAM Roles**
  * Terraform can assume another IAM role after initial authentication.
  * Example:
    ```hcl
    provider "aws" {
      assume_role {
        role_arn     = "arn:aws:iam::123456789012:role/MyRole"
        session_name = "TerraformSession"
        external_id  = "MyExternalID"
      }
    }
    ```
  * Common when you need Terraform to access cross-account resources securely.

* **Assuming IAM Role with Web Identity**
  * Used for OIDC-based authentication (like EKS pods).
  * Example:
    ```hcl
    provider "aws" {
      assume_role_with_web_identity {
        role_arn                = "arn:aws:iam::123456789012:role/MyRole"
        session_name            = "TerraformOIDCSession"
        web_identity_token_file = "/path/to/web-identity-token"
      }
    }
    ```
  * Recommended for Kubernetes (EKS) and CI/CD systems using OpenID Connect.


<br>

* **Multiple Providers Example**
```hcl
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

resource "aws_instance" "india" {
  provider = aws.mumbai
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_instance" "us" {
  provider = aws.us
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```
* Now Terraform can manage instances across multiple AWS regions simultaneously.

* **Provider Installation**
  * Terraform will:
    * Set up the backend – prepares where Terraform will store the state file (local by default).
    * Download provider plugins – installs the AWS provider plugin needed for your configuration.
    * Create a .terraform.lock.hcl file – records the exact provider version used, so the same version is used next time.
    * Create a .terraform/ folder – stores the provider binary files.
    * After terraform init, providers are stored here:
      ```bash
      .terraform/
      └── providers/
          └── registry.terraform.io/
              └── hashicorp/
                  └── aws/
                      └── 5.0.1/

      
      ```

<br>

* **Provider Debugging**
* If something goes wrong with a provider (e.g., authentication failure, API error), you can debug:
```bash
export TF_LOG=DEBUG
terraform apply
```
* or check provider version:
  ```bash
  terraform providers
  ```

<br>

#### Parameters
* **Region**
  * Defines the **AWS Region** where Terraform should create or manage resources.
  * Examples:
    * `us-east-1` → N. Virginia
    * `ap-south-1` → Mumbai
  * Many AWS services are region-specific, so Terraform needs to know *where* to deploy.
    ```hcl
    provider "aws" {
      region = "ap-south-1"
    }
    ```

<br>

* **access_key**
  * The **AWS access key ID** is like a username for programmatic access to your AWS account.
  * It authenticates Terraform to AWS, allowing it to make API calls.
  * Do **not** hardcode it in your `.tf` files. Instead, use environment variables or AWS CLI credentials.
    ```hcl
    provider "aws" {
      access_key = "AKIAIOSFODNN7EXAMPLE"
      secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
    ```

<br>

* **Secure way:**
  ```bash
  export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
  export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  ```
  * Terraform automatically picks them up.

<br>

* **secret_key**
  * The **AWS secret access key** works as the password paired with your access key ID.
  * It signs the API requests Terraform makes to AWS.
  * Never share or commit this key to version control (GitHub, GitLab, etc.).
    ```bash
    export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    ```

<br>

* **assume_role**
  * Lets Terraform **assume an IAM role** instead of using direct credentials.
  * When you’re working in a large organization and must assume a role for cross-account access.
  * When using AWS SSO or federated login setups.
    ```hcl
    provider "aws" {
      region = "us-east-1"

      assume_role {
        role_arn     = "arn:aws:iam::123456789012:role/TerraformAccessRole"
        session_name = "TerraformSession"
        external_id  = "12345"   # optional, used for added security
      }
    }
    ```
  * Terraform uses your base credentials to call the AWS STS `AssumeRole` API and temporarily acts as that role.

<br>

* **token**
  * Used when you’re working with **temporary credentials**, such as:
    * AWS STS sessions
    * AWS CLI SSO sessions
    * IAM roles assumed with MFA
    ```bash
    export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjENL//////////wEaCXVzLWVhc3QtMSJG..."
    ```
  * Terraform automatically detects and uses this token for session-based authentication.

<br>

* **Complete Example**
  ```hcl
  provider "aws" {
    region     = "ap-south-1"
    access_key = "YOUR_ACCESS_KEY"
    secret_key = "YOUR_SECRET_KEY"

    assume_role {
      role_arn     = "arn:aws:iam::111122223333:role/AdminRole"
      session_name = "TerraformSession"
    }

    token = "YOUR_TEMP_SESSION_TOKEN"
  }
  ```

---

### **Terraform AWS provider issues**

* **1. Error: Invalid Credentials**
    * **Cause:** Terraform cannot authenticate to AWS due to incorrect or missing credentials.
    * **Possible Solutions:**

      * **S1:** Check your credentials file → `~/.aws/credentials`
        Ensure `aws_access_key_id` and `aws_secret_access_key` are correct and not expired.
        Example:

        ```ini
        [default]
        aws_access_key_id = YOUR_ACCESS_KEY
        aws_secret_access_key = YOUR_SECRET_KEY
        ```
      * **S2:** If using environment variables, verify they’re exported correctly:

        ```bash
        echo $AWS_ACCESS_KEY_ID
        echo $AWS_SECRET_ACCESS_KEY
        ```
      * **S3:** If assuming a role, confirm:

        * The **role exists** in AWS IAM.
        * The **role ARN** and **session name** are correct in your provider block.
        * Example:

          ```hcl
          assume_role {
            role_arn     = "arn:aws:iam::123456789012:role/MyRole"
            session_name = "TerraformSession"
          }
          ```

* **2. Unsupported or Invalid Region**
  * **Cause:** Terraform is trying to use a region that doesn’t exist or isn’t enabled in your AWS account.
  * **Possible Solutions:**
    * **S1:** Check if the region is valid → [AWS Region List](https://docs.aws.amazon.com/general/latest/gr/rande.html).
      Example valid regions: `us-east-1`, `ap-south-1`, `eu-west-3`
    * **S2:** Verify your region configuration:

      * In Terraform:

        ```hcl
        provider "aws" {
          region = "ap-south-1"
        }
        ```
      * Or via environment variable:

        ```bash
        echo $AWS_REGION
        ```
    * **S3:** Ensure the region is **enabled** in your AWS account (especially for new regions).


* **3. Permission Denied to Create or Update a Resource**
  * **Cause:** The IAM user or role used by Terraform lacks the required permissions.
  * **Possible Solutions:**
    * **S1:** Verify your IAM user or role policy allows the required actions.
      Example minimal S3 bucket policy:

      ```json
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "s3:CreateBucket",
              "s3:PutBucketPolicy"
            ],
            "Resource": "*"
          }
        ]
      }
      ```
    * **S2:** If you’re assuming a role, confirm the **trust policy** allows your user or service to assume it.
    * **S3:** Try running the same operation via the AWS CLI to verify permission issues:

      ```bash
      aws s3api create-bucket --bucket test-bucket --region ap-south-1
      ```

* **4. Invalid Resource Configuration**
  * **Cause:** The resource syntax or attributes don’t match the provider version you’re using.
  * **Possible Solutions:**
    * **S1:** Check your current AWS provider version:

      ```bash
      terraform providers
      ```
    * **S2:** Compare with the documentation for that version on the [Terraform AWS provider registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).
    * **S3:** Upgrade to the latest provider version:

      ```bash
      terraform init -upgrade
      ```
    * **S4:** If the configuration worked before and suddenly fails, check the `.terraform.lock.hcl` file for version drift.

---

Here is the **clear, exact explanation** of the Terraform `provider_installation` block — what it is, why we use it, and how to configure it to use a **local provider mirror**.

This is **100% correct Terraform syntax**, valid for Terraform 1.x and above.

---

# ✔ What is `provider_installation`?

Terraform normally downloads providers from:

* Terraform Registry (registry.terraform.io)
* HashiCorp releases IAM
* Private registries (if configured)

But sometimes you **do NOT want Terraform to download from the internet**.

You may want to:

* Use a **local mirror**
* Use an **internal company registry**
* Avoid internet access for security reasons
* Speed up provider downloads
* Work in offline/air-gapped environments

To override Terraform’s default provider download behavior, you configure:

```
provider_installation { ... }
```

inside a `.terraformrc` (CLI config) or `terraform.rc` file.

---

# ✔ Location of the Config File

### **Linux / macOS**

```
~/.terraformrc
```

### **Windows**

```
%APPDATA%\terraform.rc
```

For Git Bash:

```
/c/Users/<USERNAME>/AppData/Roaming/terraform.rc
```

---

# ✔ Full Example: Use Local Provider Mirror

Create directory to store mirrored providers:

```bash
mkdir -p ~/terraform-providers
```

Add providers manually or using `terraform providers mirror`:

```bash
terraform providers mirror ~/terraform-providers
```

This downloads all required providers into the folder.

---

Now create your config file:

### `~/.terraformrc` (Linux/macOS)

### `terraform.rc` (Windows)

Add:

```hcl
provider_installation {
  filesystem_mirror {
    path    = "C:/Users/ADMIN/terraform-providers"
    include = ["hashicorp/aws", "hashicorp/azurerm"]
  }

  direct {
    exclude = ["hashicorp/aws", "hashicorp/azurerm"]
  }
}
```

---

# ✔ What This Configuration Means

### ✔ 1. `filesystem_mirror`

Terraform will **install providers from your local folder** instead of downloading them.

### ✔ 2. `include`

These specific providers are taken **only** from the local mirror.

Example above includes:

* `hashicorp/aws`
* `hashicorp/azurerm`

### ✔ 3. `direct` block

All other providers (not listed in `include`) will be downloaded normally from the registry.

---

# ✔ If You Want to Block ALL External Downloads

Use this:

```hcl
provider_installation {
  filesystem_mirror {
    path    = "C:/Users/ADMIN/terraform-providers"
  }

  # Block all external downloads
  direct {
    exclude = ["*"]
  }
}
```

This makes Terraform work in **offline mode**, using only local providers.

---

# ✔ Use Case: Air-Gapped or Restricted Environments

If internet is blocked, use:

```hcl
provider_installation {
  filesystem_mirror {
    path = "/opt/terraform/providers"
  }
}
```

Now Terraform will fail if provider is missing → good for strict infra.

---

# ✔ Generate Local Provider Mirror Automatically

Terraform supports:

```bash
terraform providers mirror /path/to/mirror
```

Example:

```bash
terraform providers mirror C:/tf-mirror
```

This downloads all providers required by your Terraform configuration into that folder.

---

# ✔ Validate It Is Working

Run:

```bash
terraform init -upgrade
```

You should see:

```
Installing hashicorp/aws v5.46.0 from local mirror
Installing hashicorp/azurerm v4.54.0 from local mirror
```

instead of:

```
Downloading hashicorp/aws...
```

---
