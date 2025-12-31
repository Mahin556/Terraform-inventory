```bash
* Below is a FULL, COMPLETE, WORKING Terraform + Vault example
* Uses Vault KV v2 (recommended)
* Token is passed via environment variable
* Secrets are read from Vault and written to a local file
* You can copy–paste and run directly

------------------------------------------------------------

* Vault side (run once before Terraform)

vault secrets enable -path=secret kv-v2

vault kv put secret/myapp/database \
  mysql_username=root \
  mysql_password=admin123

------------------------------------------------------------

* Export Vault token (DO NOT hardcode)

export TF_VAR_vault_token="hvs.xxxxxxxxxxxxxxxxx"
export VAULT_ADDR="http://127.0.0.1:8200"

------------------------------------------------------------

* versions.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

------------------------------------------------------------

* variables.tf

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
  sensitive   = true
}

------------------------------------------------------------

* provider.tf

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}

------------------------------------------------------------

* main.tf

data "vault_kv_secret_v2" "database" {
  mount = "secret"
  name  = "myapp/database"
}

resource "local_file" "credentials_file" {
  filename = "${path.module}/mysql_credentials.txt"

  content = <<EOT
MySQL Username: ${data.vault_kv_secret_v2.database.data["mysql_username"]}
MySQL Password: ${data.vault_kv_secret_v2.database.data["mysql_password"]}
EOT
}

------------------------------------------------------------

* .gitignore (VERY IMPORTANT)

*.tfstate
*.tfstate.backup
.terraform/
mysql_credentials.txt

------------------------------------------------------------

* Run Terraform

terraform init
terraform plan
terraform apply

------------------------------------------------------------

* Result
  * Vault secret is read securely
  * mysql_credentials.txt file is created
  * Content is populated from Vault at apply time

------------------------------------------------------------

* Critical security notes
  * Secrets are stored in terraform.tfstate
  * Never commit state files
  * local_file is for learning/demo only
  * In production:
    * Inject secrets into applications
    * Use AppRole / Kubernetes auth
    * Avoid writing secrets to disk
```

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
  sensitive   = true
}

provider "vault" {
  address          = "http://192.168.29.173:8200"
  skip_child_token = true
  token = var.vault_token
}

data "vault_kv_secret_v2" "database" {
  mount = "secret"
  name  = "myapp/database"
}

resource "local_file" "credentials_file" {
  filename = "${path.module}/mysql_credentials.txt"

  content = <<EOT
MySQL Username: ${data.vault_kv_secret_v2.database.data["mysql_username"]}
MySQL Password: ${data.vault_kv_secret_v2.database.data["mysql_password"]}
EOT
}
```
