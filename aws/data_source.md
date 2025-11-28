* Used to fetch the info about existing resources on cloud or info about things provided by the cloud provider.
* Using data source we can use the existing resource, and avoid hardcoding.
* Make config dynamic (latest AMI, existing VPC ID, etc.)
* It fetch the info at time of plan and update at time of apply.
* Read secrets from SSM/Secret Manager
* Fetch existing IAM roles
* Read external API values

```hcl
data "<provider>_<resource>" "<name>" {
  # arguments (optional)
}
```

```hcl
#GET VPC ID
data "aws_vpc" "vpc-id" {
  tags = {
    Name = "my-vpc"
  }
}

#OUTPUT VPC ID
output "vpc-id" {
  value = data.aws_vpc.vpc-id.id
}

#GET SUBNET ID
data "aws_subnet" "public-subnet" {
  vpc_id = data.aws_vpc.vpc-id.id
#   filter{
#     name = "vpc-id"
#     value = data.aws_vpc.vpc-id.id
#   }
  tags = {
    Name = "public_subnet"
    ENV  = "PROD"
  }
}

#OUTPUT SUBNET ID
output "subnet-id" {
  value = data.aws_subnet.public-subnet.id
}

#GET AMI ID
data "aws_ami" "ami-id" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

output "ami-id" {
  value = data.aws_ami.ami-id.id
}

#GET SECURITY GROUP ID
data "aws_security_group" "security-group-id" {
    vpc_id = data.aws_vpc.vpc-id.id
    tags = {
        Name = "my-sg"
        ENV  = "PROD"
    }
}

output "sg-id" {
  value = data.aws_security_group.security-group-id.id
}

#USING DATA SOURCE INFORMATION IN THE INSTANCE RESOURCE BLOCK
resource "aws_instance" "nginx-server" {
  ami                    = data.aws_ami.ami-id.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public-subnet.id
  security_groups = [ data.aws_security_group.security-group-id.id ]
  associate_public_ip_address = true
  tags = {
    Name = "nginx-server"
  }
  user_data =<<-EOF
        #!/bin/bash
        sudo yum install nginx -y
        sudo systemctl start nginx
        echo -e "Hostname:- $(hostname) \t IP:- $(hostname -I)"
        EOF
}
```

---

* **VPC**
```hcl
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["prod-vpc"]
  }
}

resource "aws_subnet" "web" {
  vpc_id = data.aws_vpc.main.id
  cidr_block = "10.10.1.0/24"
}

```

---

**Get the current caller identity (your AWS account info)**
```hcl
data "aws_caller_identity" "account" {
}
output "aws_account" {
  value = data.aws_caller_identity.account
}
output "aws_account" {
  value = data.aws_caller_identity.account.id
}
```
---

* **Data Sources ARE stored in the Terraform State**
  * Because Terraform needs deterministic values so that apply is consistent.
    ```bash
    terraform state list

    data.aws_region.current
    data.aws_ami.amazon_linux
    ```

---

* **Interview questions**
    ```bash
    # ============================================================
    # Terraform Data Sources – Full Interview Q&A (All in One Box)
    # ============================================================

    # ⭐ Q1: What is a data source in Terraform?
    # A data source is a READ-ONLY lookup. It fetches information from a provider
    # or an external system without creating infrastructure.

    # ⭐ Q2: Does a data source create resources?
    # No. Data sources NEVER create, update, or delete real infrastructure.
    # They only read and return information.

    # ⭐ Q3: When are data sources evaluated?
    # Data sources are evaluated during:
    #   - terraform plan
    #   - terraform apply (refresh phase)
    # Terraform must know these values before creating dependent resources.

    # ⭐ Q4: Are data sources stored in the state file?
    # Yes. The results of data sources are stored in the state file so that:
    #   - dependent resources can use them
    #   - Terraform behaves consistently
    #   - values do not need to be fetched again on every run

    # ⭐ Q5: Why use data sources?
    # To avoid hardcoding and to fetch DYNAMIC or EXISTING info, such as:
    #   - Latest AMI
    #   - Existing VPCs/Subnets
    #   - IAM roles
    #   - Secrets from AWS Secrets Manager
    #   - Existing S3 buckets, IPs, etc.
    # Data sources make Terraform reusable, DRY, and environment-agnostic.

    # ⭐ Q6: Example: Fetching the latest Amazon Linux AMI
    data "aws_ami" "latest_amazon_linux" {
    owners = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    most_recent = true
    }

    # Usage:
    # ami = data.aws_ami.latest_amazon_linux.id
    # ============================================================
    ```

---

**To get current/default region**
```bash
aws configure set default.region
or
export AWS_REGION="us-east-1"
```
Terraform Region Priority = `Region in provider block` --> `AWS_REGION` --> `AWS_DEFAULT_REGION` --> `~/.aws/config`

| Tool / Service                              | Uses `AWS_REGION`               | Uses `AWS_DEFAULT_REGION` |
| ------------------------------------------- | ------------------------------- | ------------------------- |
| **Terraform**                               | ✅ Yes (primary)                 | ❌ No                      |
| **AWS CLI**                                 | ❌ Only if AWS_REGION is missing | ✅ Yes (primary)           |
| **AWS SDKs (Python boto3, Go, Java, etc.)** | ✅ Yes                           | ❌ No                      |
| **Ansible AWS Modules**                     | ✅ Yes                           | ❌ No                      |
| **Packer**                                  | ✅ Yes                           | ❌ No                      |


```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = "~> 1.12.0"
}

provider "aws" {
  #If we skip the region in provider block terraform user the default region in `aws configure` or `AWS_DEFAULT_REGION` environment variable 
  #region = "ap-south-1" #overwrite the `aws configure` or `AWS_DEFAULT_REGION` environment variable
  profile = "tf-user"
}

#To get region
data "aws_region" "region" {
}

output "aws_region" {
  value = data.aws_region.region
}
```
Output:
    ```bash
    + aws_region  = {
        + description = "US East (N. Virginia)"
        + endpoint    = "ec2.us-east-1.amazonaws.com"
        + id          = "us-east-1"
        + name        = "us-east-1"
        }
    ```

---

**Available availablity zones**
```hcl
data "aws_availability_zones" "zones" {
  state = "available"
}
output "zone-names2" {
  value = data.aws_availability_zones.zones
}
output "zone-names" {
  value = data.aws_availability_zones.zones.names
}
```
Output:
```bash
Changes to Outputs:
  + zone-names  = [
      + "us-east-1a",
      + "us-east-1b",
      + "us-east-1c",
      + "us-east-1d",
      + "us-east-1e",
      + "us-east-1f",
    ]
  + zone-names2 = {
      + all_availability_zones = null
      + exclude_names          = null
      + exclude_zone_ids       = null
      + filter                 = null
      + group_names            = [
          + "us-east-1-zg-1",
        ]
      + id                     = "us-east-1"
      + names                  = [
          + "us-east-1a",
          + "us-east-1b",
          + "us-east-1c",
          + "us-east-1d",
          + "us-east-1e",
          + "us-east-1f",
        ]
      + state                  = "available"
      + timeouts               = null
      + zone_ids               = [
          + "use1-az6",
          + "use1-az1",
          + "use1-az2",
          + "use1-az4",
          + "use1-az3",
          + "use1-az5",
        ]
    }
```

---

* Security group

```hcl
data "aws_security_group" "sg" {
  tags = {
    ENV  = "PROD"
    Name = "my-sg"
  }
}
output "sg-id" {
  value = data.aws_security_group.sg.id
}
```

---

* Fetching AMI info
```hcl
data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  # name_regex = "^amzn2-ami"

  # filter {
  #     name   = "name"
  #     values = ["amzn2*"]
  # }

  # filter {
  #     name   = "root-device-type"
  #     values = ["ebs"]
  # }

  # filter {
  #     name   = "virtualization-type"
  #     values = ["hvm"]
  # }
}

output "aws_ami1" {
  value = data.aws_ami.ami_id
}

output "aws_ami2" {
  value = data.aws_ami.ami_id.id
}
```

---

* **Get ECR login password**
```hcl
data "aws_ecr_authorization_token" "token" {}

output "docker_login_cmd" {
  value = "docker login --username AWS --password ${data.aws_ecr_authorization_token.token.password} ${data.aws_ecr_authorization_token.token.proxy_endpoint}"
}
```
---

```hcl
data "aws_vpc" "name" {
  cidr_block = "172.31.0.0/16"
}
```

---