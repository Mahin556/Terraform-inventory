```bash
====================== TERRAFORM LIFECYCLE META-ARGUMENT ======================
        RESOURCE CREATION • UPDATE • DELETION CONTROL (DETAILED)
=============================================================================

WHAT IS `lifecycle`?
* `lifecycle` is a **Terraform meta-argument**
* It controls **HOW Terraform behaves**, not what cloud resource is created
* It affects:
  - Creation
  - Update
  - Destruction
* Applies to **any resource**, regardless of provider

Think of `lifecycle` as:
🔒 🚦 **Safety & behavior rules for your infrastructure**

-----------------------------------------------------------------------------

WHY `lifecycle` IS IMPORTANT
* Prevents accidental destruction
* Reduces downtime during replacement
* Allows coexistence with manual / external changes
* Commonly used for:
  - Databases
  - Load balancers
  - Auto Scaling Groups
  - Production EC2 / EKS / RDS

-----------------------------------------------------------------------------

1️⃣ prevent_destroy
-----------------

WHAT IT DOES
* Completely blocks Terraform from destroying a resource
* Even if:
  - You run `terraform destroy`
  - You remove the resource from `.tf` file

Example:
lifecycle {
  prevent_destroy = true
}

BEHIND THE SCENES
* Terraform plan will fail with an error
* Forces human intervention

Typical use cases:
* Databases (RDS, MongoDB, PostgreSQL)
* Production S3 buckets
* Critical IAM resources

Example scenario:
* Someone runs `terraform destroy`
* Terraform stops and says:
  ❌ "Resource is protected by prevent_destroy"

-----------------------------------------------------------------------------

2️⃣ create_before_destroy
-------------------------

WHAT IT DOES
* Creates the **new resource first**
* Deletes the **old resource later**

Example:
lifecycle {
  create_before_destroy = true
}

BEHIND THE SCENES
* Terraform changes execution order:
  1. Create new resource
  2. Switch dependencies
  3. Destroy old resource

Why this matters:
* Prevents downtime
* Avoids service disruption

Typical use cases:
* Databases
* Load balancers
* EC2 instances behind ALB
* Launch templates

Important note:
* Resource must support parallel existence
* Some resources require unique names → may fail

-----------------------------------------------------------------------------

3️⃣ ignore_changes
------------------

WHAT IT DOES
* Tells Terraform to **ignore changes** to specific attributes
* Terraform will NOT try to revert those values

Example:
lifecycle {
  ignore_changes = [instance_type]
}

BEHIND THE SCENES
* Terraform still tracks the resource
* But ignores diffs for specified fields

Why this is needed:
* Terraform enforces desired state
* External systems may change values

Common use cases:
* EC2 instance_type changed manually
* Auto Scaling Groups:
  - min_size
  - max_size
  - desired_capacity
* Tags updated by other tools
* Kubernetes-managed resources

Advanced example:
lifecycle {
  ignore_changes = [
    tags,
    desired_capacity
  ]
}

-----------------------------------------------------------------------------

COMMON MISTAKES
---------------

❌ Thinking lifecycle is provider-specific  
✅ lifecycle is Terraform core

❌ Using ignore_changes for everything  
✅ Use it selectively (least privilege)

❌ Using create_before_destroy on name-locked resources  
✅ Ensure resource supports replacement

-----------------------------------------------------------------------------

WHEN TO USE WHAT (QUICK GUIDE)
------------------------------

* protect data → prevent_destroy
* avoid downtime → create_before_destroy
* coexist with autoscaling/manual changes → ignore_changes

-----------------------------------------------------------------------------

REAL-WORLD EXAMPLE
------------------

resource "aws_db_instance" "prod" {
  allocated_storage = 20
  engine            = "postgres"
  instance_class    = "db.t3.medium"

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
  }
}

WHAT THIS ACHIEVES
* DB cannot be deleted accidentally
* DB replacement happens safely
* Production-safe configuration

-----------------------------------------------------------------------------

KEY TAKEAWAYS
-------------

* lifecycle controls Terraform behavior
* Extremely important for production
* Protects critical infrastructure
* Common interview topic

-----------------------------------------------------------------------------

ONE-LINE INTERVIEW ANSWER
------------------------

"The lifecycle meta-argument controls how Terraform creates, updates, and deletes
resources using rules like prevent_destroy, create_before_destroy, and ignore_changes."

=============================================================================
```
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "vpc-name" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_instance" "demo-instance" {
  ami = "ami-0a1235697f4afa8a4"
  instance_type = "t2.micro"

  lifecycle {
    precondition {
      condition = aws_vpc.vpc-name.id != ""
      error_message = "VPC ID Can't be Empty"
    }
    postcondition {
      condition = self.public_ip != ""
      error_message = "Public IP Can't be Empty"
    }
  }
}
```