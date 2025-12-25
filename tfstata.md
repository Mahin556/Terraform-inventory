* Store info about what resources a terrform managing on the cloud.
* Json
* Collaboration
* State locking
* tf compare actual state(tfstate) with the desire state(*.tf) to take a decision what to create or what to destroy.
* Based on this file terraform take decision --> which resource to add, which resource to update and whihc resource to delete other wise terraform will build infra on every run.
* Can place it on local or remote 

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

resource "aws_instance" "ec2-instance" {
  ami           = "ami-0521bc4c70257a054" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  tags = {
    Name = "TestInstance"
  }
}
```
```json
{
  "version": 4,
  "terraform_version": "1.12.2",
  "serial": 1,
  "lineage": "54a48967-f93e-e511-24fc-5b25b66aeab0",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "ec2-instance",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0521bc4c70257a054",
            "arn": "arn:aws:ec2:ap-south-1:361769558190:instance/i-0a954df13689dcc94",
            "associate_public_ip_address": true,
            "availability_zone": "ap-south-1b",
            "capacity_reservation_specification": [
              {
                "capacity_reservation_preference": "open",
                "capacity_reservation_target": []
              }
            ],
            "cpu_core_count": 1,
            "cpu_options": [
              {
                "amd_sev_snp": "",
                "core_count": 1,
                "threads_per_core": 1
              }
            ],
            "cpu_threads_per_core": 1,
            "credit_specification": [
              {
                "cpu_credits": "standard"
              }
            ],
            "disable_api_stop": false,
            "disable_api_termination": false,
            "ebs_block_device": [],
            "ebs_optimized": false,
            "enable_primary_ipv6": null,
            "enclave_options": [
              {
                "enabled": false
              }
            ],
            "ephemeral_block_device": [],
            "get_password_data": false,
            "hibernation": false,
            "host_id": "",
            "host_resource_group_arn": null,
            "iam_instance_profile": "",
            "id": "i-0a954df13689dcc94",
            "instance_initiated_shutdown_behavior": "stop",
            "instance_lifecycle": "",
            "instance_market_options": [],
            "instance_state": "running",
            "instance_type": "t2.micro",
            "ipv6_address_count": 0,
            "ipv6_addresses": [],
            "key_name": "",
            "launch_template": [],
            "maintenance_options": [
              {
                "auto_recovery": "default"
              }
            ],
            "metadata_options": [
              {
                "http_endpoint": "enabled",
                "http_protocol_ipv6": "disabled",
                "http_put_response_hop_limit": 1,
                "http_tokens": "optional",
                "instance_metadata_tags": "disabled"
              }
            ],
            "monitoring": false,
            "network_interface": [],
            "outpost_arn": "",
            "password_data": "",
            "placement_group": "",
            "placement_partition_number": 0,
            "primary_network_interface_id": "eni-02ad68937eab4744e",
            "private_dns": "ip-172-31-15-138.ap-south-1.compute.internal",
            "private_dns_name_options": [
              {
                "enable_resource_name_dns_a_record": false,
                "enable_resource_name_dns_aaaa_record": false,
                "hostname_type": "ip-name"
              }
            ],
            "private_ip": "172.31.15.138",
            "public_dns": "ec2-13-203-218-135.ap-south-1.compute.amazonaws.com",
            "public_ip": "13.203.218.135",
            "root_block_device": [
              {
                "delete_on_termination": true,
                "device_name": "/dev/sda1",
                "encrypted": false,
                "iops": 3000,
                "kms_key_id": "",
                "tags": {},
                "tags_all": {},
                "throughput": 125,
                "volume_id": "vol-071de00add36ff117",
                "volume_size": 10,
                "volume_type": "gp3"
              }
            ],
            "secondary_private_ips": [],
            "security_groups": [
              "default"
            ],
            "source_dest_check": true,
            "spot_instance_request_id": "",
            "subnet_id": "subnet-0946a20433778b7f4",
            "tags": {
              "Name": "TestInstance"
            },
            "tags_all": {
              "Name": "TestInstance"
            },
            "tenancy": "default",
            "timeouts": null,
            "user_data": null,
            "user_data_base64": null,
            "user_data_replace_on_change": false,
            "volume_tags": null,
            "vpc_security_group_ids": [
              "sg-051979e5734a9c806"
            ]
          },
          "sensitive_attributes": [],
          "identity_schema_version": 0,
          "private": "eyJlMmJmYjczMC1lY2FhLTExZTYtOGY4OC0zNDM2M2JjN2M0YzAiOnsiY3JlYXRlIjo2MDAwMDAwMDAwMDAsImRlbGV0ZSI6MTIwMDAwMDAwMDAwMCwicmVhZCI6OTAwMDAwMDAwMDAwLCJ1cGRhdGUiOjYwMDAwMDAwMDAwMH0sInNjaGVtYV92ZXJzaW9uIjoiMSJ9"
        }
      ]
    }
  ],
  "check_results": null
}
```





---

### Remote state

• When working on a **personal or small project**, keeping the `terraform.tfstate` file **locally** is acceptable as long as you maintain proper security, backups, and avoid committing it to version control.

• In a **team or collaborative environment**, a **remote backend** is essential. Storing the state file remotely ensures that everyone works with a **shared, consistent state**, prevents conflicts through **state locking**, and provides reliable backups and versioning.

• In **automation workflows or CI/CD pipelines**, service principals or automation agents also require access to the Terraform state. A **remote backend** allows the pipeline to securely access the state, apply changes, and enforce proper access control policies.

* Remote state management solutions:
  * *Azure Storage accounts* 
  * *Amazon S3 buckets* are an ideal choice. 
  * *Spacelift* to manage your state for you.

* Remote state file localtion can be refer in `backend` block in terraform
  * AWS S3
    ```hcl
    terraform {
      backend "s3" {
        bucket         = "mahin-terraform-state-bucket"
        key            = "envs/dev/terraform.tfstate"
        region         = "ap-south-1"
        dynamodb_table = "terraform-locks"
        encrypt        = true
      }
    }
    ```
  * Azure Storage Account
    ```hcl
    terraform {
      backend "azurerm" {
        resource_group_name  = "terraform-rg"
        storage_account_name = "terraformsa"
        container_name       = "terraformstate"
        key                  = "terraform.tfstate"
      }
    }
    ```

* WHY YOU SHOULD *NOT* STORE TERRAFORM STATE FILES IN GIT
  ```bash
  # 1️⃣ STATE FILE CONTAINS SENSITIVE DATA
  # --------------------------------------
  # Terraform state (.tfstate) stores EVERYTHING in plain text:
  #   • passwords
  #   • private keys
  #   • database credentials
  #   • IAM secrets
  #   • resource IDs & attributes
  # Storing this in Git exposes secrets to ANYONE with repo access.
  # Git = NOT a secure storage → NO encryption → HIGH security risk.

  # 2️⃣ NO FILE LOCKING IN GIT
  # --------------------------
  # Git cannot lock the state file.
  # Terraform needs exclusive access to modify the state.
  # Without locking:
  #   • multiple people may run terraform apply at the same time
  #   • both update the same state file
  #   • results in state corruption and unpredictable infra changes

  # 3️⃣ RISK OF USING OUTDATED STATE (HUMAN ERROR)
  # ----------------------------------------------
  # If state is in Git:
  #   • you must manually git pull before every apply
  #   • you must manually git commit + push after every apply
  # Forgetting either = Terraform reads outdated state.
  # Outdated state = Terraform thinks resources changed → may delete or recreate.

  # 4️⃣ MERGE CONFLICTS IN TFSTATE ARE DANGEROUS
  # --------------------------------------------
  # tfstate is a large JSON file.
  # If two developers modify it:
  #   • Git creates merge conflicts
  #   • Resolving manually is extremely risky
  #   • Wrong conflict resolution can destroy live infrastructure

  # 5️⃣ VERSION CONTROL SYSTEMS ARE NOT DESIGNED FOR STATE MGMT
  # -----------------------------------------------------------
  # Git provides:
  #   • versioning
  #   • branching
  # But NOT:
  #   • encryption
  #   • locking
  #   • auto state refresh
  #   • consistency guarantees
  # All of these are REQUIRED for Terraform to work safely.
  ```

* WHY REMOTE BACKENDS SOLVE EVERYTHING
  ```bash
  # 1️⃣ REMOTE BACKENDS PROVIDE STATE LOCKING
  # -----------------------------------------
  # Examples:
  #   • S3 + DynamoDB → locking
  #   • Azure Storage → locking
  #   • GCS → locking
  #   • Terraform Cloud → locking
  # Locking prevents simultaneous writes → prevents corruption.

  # 2️⃣ ALWAYS LOADS LATEST STATE AUTOMATICALLY
  # -------------------------------------------
  # Terraform automatically fetches the latest state from backend.
  # No manual git pull needed → eliminates human error.

  # 3️⃣ ENCRYPTION SUPPORTED (AT REST + IN TRANSIT)
  # -----------------------------------------------
  # S3, Azure, GCS:
  #   • HTTPS encryption in transit
  #   • Server-side encryption (SSE) at rest
  # Secrets never appear in Git.

  # 4️⃣ STATE VERSIONING FOR FREE
  # -----------------------------
  # Cloud storage supports versioning:
  #   • S3 versioning
  #   • Azure blob versioning
  #   • GCS object versioning
  # You can roll back to older tfstate if corruption happens.

  # 5️⃣ HIGH AVAILABILITY & DURABILITY
  # ----------------------------------
  # State is accessible from anywhere.
  # Stored in multi-AZ cloud storage.
  # Much safer than storing state locally or in Git repo.

  # 6️⃣ COST IS VERY LOW
  # ---------------------
  # tfstate is usually < 500 KB.
  # Most cloud vendors store it within free tier.
  ```

---

### Recover tfstate

```hcl
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "mahin-unique-bucket-name-123456"
  tags = {
    "Name" = "mahin-unique-bucket-name-123456"
  }
}
```
```bash
terraform init
terraform plan
terraform apply 

$ terraform.exe state list
aws_s3_bucket.my-bucket

rm -rf terraform.tfstate

terraform.exe import aws_s3_bucket.my-bucket mahin-unique-bucket-name-123456

$ terraform.exe state list
aws_s3_bucket.my-bucket
```

---

* TF State Migration:
```bash
aws s3api create-bucket \
  --bucket mahin-terraform-state-bucket \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket mahin-terraform-state-bucket \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --billing-mode PAY_PER_REQUEST
```
```hcl
terraform {
  backend "s3" {
    bucket         = "mahin-terraform-state-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
```bash
terraform init -migrate-state
#Local to Remote
```

* Remote state using terraform (s3 + dynamodb)
  ```hcl
  terraform {
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = ">= 5.0.0"
      }
    }
  }

  provider "aws" {
    region = "ap-south-1"
    profile = "tf-user"
  }

  resource "aws_s3_bucket" "backend" {
    bucket = "mahin-s3-backend-123456"
    tags = {
      "Name" = "mahin-s3-backend-123456"
      "Environment" = "Dev"
    }
  }

  resource "aws_s3_bucket_versioning" "versioning_example" {
    bucket = aws_s3_bucket.backend.id
    versioning_configuration {
      status = "Enabled"
    }
  }

  resource "aws_s3_bucket_server_side_encryption_configuration" "sse_example" {
    bucket = aws_s3_bucket.backend.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  output "s3_bucket_name" {
    value = aws_s3_bucket.backend.bucket
  }

  resource "aws_dynamodb_table" "locking_table" {
    name         = "mahin-locking-table-123456"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }

    tags = {
      "Name" = "mahin-locking-table-123456"
      "Environment" = "Dev"
    } 
  }
  ```
  ```hcl
  terraform {
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = ">= 5.0.0"
      }
    }
    backend "s3" {
      bucket = "mahin-s3-backend-123456"
      key = "testing/terraform.tfstate"
      region = "ap-south-1"
      profile = "tf-user"
      dynamodb_table = "mahin-locking-table-123456"
      encrypt = true
    }
  }
  ```

* Remote state using terraform (s3)

* Deleting a version enabled bucket
```bash
aws s3api list-object-versions --bucket mahin-s3-backend-123456

aws s3api list-object-versions --bucket mahin-s3-backend-123456 --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}, Quiet:false}'
{
    "Objects": [
        {
            "Key": "testing/terraform.tfstate",
            "VersionId": "SJ1W_A3wCx67BlHeij27I7jhYk7zc034"
        },
        {
            "Key": "testing/terraform.tfstate",
            "VersionId": "raIxTA8.KFC52u9AsZZGqmM1kdi9dN7F"
        },
        {
            "Key": "testing/terraform.tfstate",
            "VersionId": "sN3zPqgLfrYxpQOXlDOZ6ZkIhYw3zHuL"
        }
    ],
    "Quiet": null
} 

aws s3api delete-objects \
  --bucket mahin-s3-backend-123456 \
  --delete "$(aws s3api list-object-versions --bucket mahin-s3-backend-123456 \
  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}, Quiet:false}')"
```
or use `force_destroy = true` in `aws_s3_bucket` block.
```hcl
resource "aws_s3_bucket" "mybucket" {
  bucket = "my-versioned-bucket"
  force_destroy = true
}
```
* If `force_destroy = true` not present when you create a bucket then update a buckert config with it and `apply` it again then `destroy` bucket to avoid `Error: S3 bucket is not empty`
* With force_destroy = true, Terraform will:
  • remove all object versions
  • remove all delete markers
  • remove all MFA-delete objects (if MFA disabled)
  • delete the bucket successfully


### s3 inbuilt locking

```hcl
terraform {
  backend "s3" {
    bucket         = "your-state-bucket-name"
    key            = "path/to/your/terraform.tfstate"
    region         = "your-aws-region"
    use_lock_file = true
  }
}
```


### Local backend
* https://developer.hashicorp.com/terraform/language/backend/local

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate.d/prod/terraform.tfstate" # custom directory, not CWD
  }
}
```
```bash
terraform.exe init -migrate-state
terraform.exe workspace select default
terraform.exe plan -var-file=dev.tfvars
terraform.exe apply -var-file=dev.tfvars
terraform.exe destroy --auto-approve
```

---


### Other backend use cases

```hcl
###############################################################
# ✅ EVERY POSSIBLE TERRAFORM BACKEND TWEAK — WITH EXAMPLES
###############################################################

# 1. Change backend type
terraform {
  backend "s3" {}
}
terraform {
  backend "local" {}
}

# 2. Custom path for LOCAL backend only
terraform {
  backend "local" {
    path = "../states/dev/state.tfstate"
  }
}

# 3. Enable S3 encryption
backend "s3" {
  server_side_encryption = "AES256"
}

# 4. Use KMS encryption
backend "s3" {
  kms_key_id = "arn:aws:kms:region:acct:key/1234"
}

# 5. Enable DynamoDB state locking
backend "s3" {
  dynamodb_table = "tf-locks"
  encrypt        = true
}

# 6. Enable Consul locking
backend "consul" {
  lock = true
}

# 7. Reinitialize backend
terraform init -reconfigure

# 8. Upgrade backend plugins
terraform init -upgrade

# 9. Workspaces with remote backend
backend "s3" {
  key = "envs/${terraform.workspace}/state.tfstate"
}

# 10. Disable state locking (not recommended)
backend "s3" {
  lock = false
}

# 11. Backend config via external file
terraform init -backend-config="dev.hcl"

# 12. Multiple backend config files
terraform init \
  -backend-config="access.hcl" \
  -backend-config="env-dev.hcl"

# 13. Partial backend config
# main.tf
backend "s3" {
  bucket = "mybucket"
}
# CLI provides missing values
terraform init -backend-config="key=dev.tfstate"

# 14. Override backend per environment
terraform init -backend-config="key=prod.tfstate"

# 15. Use environment vars for AWS credentials
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx

# 16. Cross-account IAM role for S3 backend
backend "s3" {
  role_arn = "arn:aws:iam::111122223333:role/tf-access-role"
}

# 17. Store state in a versioned bucket
# (S3 bucket must have versioning enabled — no code change)
backend "s3" {
  versioning = true
}

# 18. Recover old state from history
aws s3api list-object-versions --bucket BUCKET --prefix KEY

# 19. Restrict access using bucket policies
# S3 bucket policy (JSON)
{
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Condition": { "Bool": { "aws:SecureTransport": "false" } }
}

# 20. Workspace-based state key
backend "s3" {
  key = "states/${terraform.workspace}/main.tfstate"
}

# 21. Encryption at rest (GCS)
backend "gcs" {
  bucket = "my-bucket"
  encryption_key = "projects/.../locations/.../keyRings/.../cryptoKeys/...”
}

# 22. HTTPS for encryption in transit
backend "http" {
  address = "https://secure.example.com/state"
}

# 23. Prefix/folder inside backend
backend "s3" {
  key = "prod/network/core.tfstate"
}

# 24. HTTP backend with auth headers
backend "http" {
  address = "https://api.example.com/state"
  update_method = "POST"
  headers = {
    Authorization = "Bearer abc123"
  }
}

# 25. GCS: service account impersonation
backend "gcs" {
  impersonate_service_account = "sa@project.iam.gserviceaccount.com"
}

# 26. Terraform Cloud backend
terraform {
  backend "remote" {
    organization = "my-org"
    workspaces {
      name = "prod"
    }
  }
}

# 27. Terraform Cloud remote execution
# Enabled by default (toggle in UI)

# 28. Terraform Cloud local execution mode
backend "remote" {
  workspaces { name = "dev" }
  hostname = "app.terraform.io"
}

# 29. Auto state locking in Terraform Cloud
# (automatic, no config needed)

# 30. Retry config (S3 / HTTP)
backend "http" {
  retry_max = 5
  retry_wait_min = 1
  retry_wait_max = 10
}

# 31. Custom S3 endpoint (MinIO / Ceph)
backend "s3" {
  endpoint = "https://minio.example.com"
  skip_credentials_validation = true
  skip_region_validation      = true
}

# 32. Avoid secrets inside .tf files
terraform init \
  -backend-config="access_key=..." \
  -backend-config="secret_key=..."

###############################################################
# IMPORTANT LIMITS
# • Backend config CANNOT use input variables
# • Backend migration requires: terraform init -reconfigure
# • Backend decides where tfstate lives — not your local folder
###############################################################
```

---

* https://spacelift.io/blog/terraform-backends#managing-terraform-remote-backends-with-spacelift

```hcl
# ┌───────────────────────────────────────────────────────────┐
# │                 TERRAFORM BACKENDS — CHEAT SHEET          │
# └───────────────────────────────────────────────────────────┘

# THEORY:
# -------
# • A *backend* in Terraform controls:
#     - WHERE state is stored
#     - HOW state is loaded/updated
#     - WHO can access it
# • Without a backend, Terraform uses the default: LOCAL backend
#   (state file stored as terraform.tfstate on disk).
# • Remote backends (S3, GCS, Azure Blob, etc.) are recommended for:
#     - Teams
#     - CI/CD
#     - Reliability, durability, locking


# ────────────────────────────────────────────────────────────
# 1. KEY BACKEND FEATURES
# ────────────────────────────────────────────────────────────

# 1) State Storage
# ----------------
# • Core job of a backend = safely store Terraform state.
# • Decides *how* Terraform reads/writes state:
#     - Local → file on disk
#     - Remote → cloud storage / services

# Common backend types:
# • local        → state on local filesystem
# • s3           → AWS S3 bucket
# • azurerm      → Azure Blob Storage
# • gcs          → Google Cloud Storage
# • http         → generic HTTP API (GET/POST/DELETE)
# • remote       → Terraform Cloud / HCP / some platforms

# Example backend block (generic form):
terraform {
  backend "TYPE" {
    # backend-specific settings
  }
}


# 2) State Locking
# ----------------
# • Prevents multiple `terraform apply` / `terraform destroy`
#   from modifying state at the same time.
# • Critical in team / CI/CD environments.
# • Behavior depends on backend:
#     - S3      → needs DynamoDB for locking
#     - azurerm → uses Blob lease locking automatically
#     - local   → uses local file lock

# 3) Partial Configuration (Security)
# -----------------------------------
# • Backend config often needs secrets (keys, tokens, etc.).
# • NEVER hardcode credentials in HCL.
# • Use *partial configuration*:
#     - Only non-sensitive values in backend block
#     - Sensitive values provided by:
#         • environment variables
#         • -backend-config=... flags
#         • separate tfbackend files (used carefully)


# ────────────────────────────────────────────────────────────
# 2. EXAMPLE — S3 BACKEND (WITH PARTIAL CONFIG + LOCKING)
# ────────────────────────────────────────────────────────────

# BAD (secrets in code — not recommended):
# ----------------------------------------
# terraform {
#   backend "s3" {
#     bucket     = "MY_BUCKET"
#     key        = "PATH/TO/KEY"
#     region     = "MY_REGION"
#     access_key = "AWS_ACCESS_KEY"
#     secret_key = "AWS_SECRET_KEY"
#   }
# }

# GOOD (partial config — prefer env vars / backend-config):
terraform {
  backend "s3" {
    bucket = "MY_BUCKET"
    key    = "PATH/TO/KEY"
    # region inferred from env/provider if possible
  }
}

# Recommended env vars:
#   AWS_ACCESS_KEY_ID        → access_key
#   AWS_SECRET_ACCESS_KEY    → secret_key
#   AWS_REGION / AWS_DEFAULT_REGION → region

# Backend config via file (optional, not ideal for long-term secrets):
#   configuration.s3.tfbackend:
#       region     = "ap-south-1"
#       access_key = "..."
#       secret_key = "..."
#
#   terraform init -backend-config=configuration.s3.tfbackend

# Backend config via CLI flags (CI-friendly):
#   terraform init \
#     -backend-config="region=${AWS_REGION}" \
#     -backend-config="access_key=${ACCESS_KEY_VAR}" \
#     -backend-config="secret_key=${SECRET_KEY_VAR}"


# S3 BACKEND PERMISSIONS (IAM)
# -----------------------------
# Minimal required for state:
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:ListBucket",
#       "Resource": "arn:aws:s3:::mybucket"
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["s3:GetObject", "s3:PutObject"],
#       "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
#     }
#   ]
# }
# • s3:DeleteObject needed if using workspaces and destroying state files.


# STATE LOCKING WITH DYNAMODB
# ---------------------------
# • Terraform uses a DynamoDB table as a lock store.

# Example IAM for DynamoDB:
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "dynamodb:DescribeTable",
#         "dynamodb:GetItem",
#         "dynamodb:PutItem",
#         "dynamodb:DeleteItem"
#       ],
#       "Resource": "arn:aws:dynamodb:*:*:table/mytable"
#     }
#   ]
# }

# Enable locking in backend:
terraform {
  backend "s3" {
    bucket         = "MY_BUCKET"
    key            = "PATH/TO/KEY"
    dynamodb_table = "YOUR_DYNAMODB_TABLE"  # enables locking
  }
}


# ────────────────────────────────────────────────────────────
# 3. EXAMPLE — AZURE BLOB STORAGE BACKEND (azurerm)
# ────────────────────────────────────────────────────────────

# BASIC PARTIAL CONFIG (NO AUTH YET):
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    # auth controlled by env vars / identity
  }
}

# AUTH METHODS:
# -------------
# 1) Access Key      → ARM_ACCESS_KEY
# 2) SAS Token       → ARM_SAS_TOKEN
# 3) Azure AD (Service Principal or Managed Identity):
#       ARM_CLIENT_ID
#       ARM_SUBSCRIPTION_ID
#       ARM_TENANT_ID
#       + either ARM_CLIENT_SECRET or cert vars OR use_oidc/use_msi


# Example with Azure AD + OIDC (Service Principal):
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc             = true
    use_azuread_auth     = true
  }
}

# Example with Managed Identity:
terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_msi              = true
    use_azuread_auth     = true
  }
}

# NOTE:
# • Azure Blob backend handles locking natively using blob leases.
# • No separate lock service like DynamoDB required.


# ────────────────────────────────────────────────────────────
# 4. LOCAL BACKEND
# ────────────────────────────────────────────────────────────

# DEFAULT BEHAVIOR:
# • If no backend block → local backend.
# • State stored under working dir:
#     .terraform/terraform.tfstate (or terraform.tfstate)

# Custom path:
terraform {
  backend "local" {
    path = "relative/path/to/terraform.tfstate"
  }
}

# NOTES:
# • Locks using the local filesystem.
# • Not suitable for shared/team/CI environments.
# • OK for:
#     - personal experiments
#     - small local-only projects


# ────────────────────────────────────────────────────────────
# 5. LOCAL vs REMOTE BACKENDS (DIFFERENCE)
# ────────────────────────────────────────────────────────────

# Local backend:
# --------------
# • State on local disk
# • Tied to that machine’s lifecycle
# • Risk of loss if disk/machine dies
# • Problematic in ephemeral CI runners (GitHub Actions, etc.)

# Remote backend:
# ---------------
# • State in shared, durable storage (S3, GCS, Azure Blob, etc.)
# • Works across multiple runners/servers
# • High durability & availability
# • Supports team collaboration + CI/CD

# RULE OF THUMB:
# • Use REMOTE backends for anything serious/team/CI.
# • Local only for quick labs or prototyping.


# ────────────────────────────────────────────────────────────
# 6. MULTIPLE BACKENDS? (WORKSPACES NOTE)
# ────────────────────────────────────────────────────────────

# • A SINGLE Terraform configuration = ONE backend type.
# • You CANNOT configure S3 + azurerm simultaneously in one config.
# • Workspaces = multiple state files per backend, not multiple backend types.

# Backends that support multiple workspaces include:
#   - s3, azurerm, gcs, consul, kubernetes, local, remote, etc.

# Example idea:
#   workspace "default" → uses s3 backend, state key: env/default
#   workspace "prod"    → same backend, different key: env/prod


# ────────────────────────────────────────────────────────────
# 7. BEST PRACTICES FOR BACKENDS
# ────────────────────────────────────────────────────────────

# ✔ Prefer remote backends for any non-trivial use
# ✔ Enable versioning (S3, GCS, Blob) for state backup/rollback
# ✔ Enable locking:
#     - S3 + DynamoDB
#     - Blob native lease, etc.
# ✔ Use partial config:
#     - Credentials from env vars / secret manager
#     - Avoid hardcoding secrets in HCL or tfbackend files
# ✔ Ensure IAM/roles are least-privilege
# ✔ Regularly back up state if backend doesn’t version automatically
# ✔ Monitor access logs for suspicious access to state

# Example minimal secure S3 backend:
terraform {
  backend "s3" {
    bucket = "my-tf-backend"
    key    = "envs/prod/terraform.tfstate"
    # region, credentials via environment variables
  }
}

# ────────────────────────────────────────────────────────────
# End of Terraform Backends Guide
# ────────────────────────────────────────────────────────────
```
