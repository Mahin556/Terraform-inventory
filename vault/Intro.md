### Simple terraform config(Take variable value form the user)
```hcl
terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = ">= 6.27.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "vault_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "vault-bucket"
    Environment = "Dev"
  }
}
```
```bash
terraform init
terraform plan
```
```bash
$ terraform.exe plan
var.bucket_name
  Enter a value: mahin-raza-unique-bucket-12345
```

---

### Variable with default (take default value not from the user)
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

variable "bucket_name" {
  type = string
  default = "mahin-raza-unique-bucket-12345"
}

resource "aws_s3_bucket" "vault_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "vault-bucket"
    Environment = "Dev"
  }
}
```
```bash
terraform plan
```

---

### Take value from the *.tfvars files
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

variable "bucket_name" {
  type = string
#   default = "mahin-raza-unique-bucket-12345"
}

resource "aws_s3_bucket" "vault_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "vault-bucket"
    Environment = "Dev"
  }
}
```
```hcl
bucket_name = "mahin-raza-unique-bucket-12345"
```
```bash
terraform plan #take value from the terraform.tfvars
terraform plan --var-file=variable.tfvars #Custom tfvars file
terraform.exe plan -var=bucket_name="mahin-raza-unique-bucket-12345" #Variable value from CLI
```

---

### Variable value from the Environment Variable

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "vault_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "vault-bucket"
    Environment = "Dev"
  }
}
```
```bash
export TF_VAR_bucket_name="mahin-raza-unique-bucket-12345"
terraform plan
```

---

### Marking Value as sensitive

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

variable "bucket_name" {
  type = string
  sensitive = true
}

output "bucket_name" {
  value = var.bucket_name
  sensitive = true
}

resource "aws_s3_bucket" "vault_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "vault-bucket"
    Environment = "Dev"
  }
}
```
```bash
export TF_VAR_bucket_name="mahin-raza-unique-bucket-12345"
terraform plan
```
```bash
# aws_s3_bucket.vault_bucket will be created
  + resource "aws_s3_bucket" "vault_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (sensitive value)  
      + bucket_domain_name          = (known after apply)
```
* Terraform will not print sensitive values in the console output(CLI).
* Terraform will still store sensitive values in the state file `terraform.tfstate` in unencrypted form, anyone with access to the state file can read them.
* Prevents secrets from appearing in:  `terraform plan` `terraform apply` `terraform output`
* Values are shown as `(sensitive value)`
* Store state file in remote backend in encrypted format for store sensitive value in secure way.


---

### User external secret management solution like: Hashicorp value, ASM etc
* Hashicorp Vault works with Ansible, terraform, Kubernetes, CI/CD tools.
* Also Provide auto rotation.
* Use Dynamic Secrets.




