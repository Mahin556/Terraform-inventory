* Providers is a Terraform meta-argument
* It is used inside a module block
* It maps provider aliases from the root module into child modules
* Important idea:
    * Modules should be provider-agnostic
    * Modules should NOT decide:
        * region
        * account
        * credentials
* That responsibility belongs to the caller, not the module.

* Why providers exists
    * Terraform rule:
        * Modules cannot automatically guess which provider alias to use
        * Provider configuration lives in the root module
        * Child modules must be explicitly told which provider to use
        * Providers solves this cleanly.

---

* Child module
```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

* Root module
```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

module "west_resources" {
  source = "./instances_module"

  providers = {
    aws = aws.west
  }
}
```
```bash
Behind the scenes (BTS)

Root module:

Creates provider aws.west

Terraform injects that provider into the module

Inside the module:

aws automatically points to aws.west

All resources in the module:

Use us-west-1

Use the same credentials
```

---

* Root Module
```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

module "east_infra" {
  source = "./ec2_module"

  providers = {
    aws = aws.east
  }

  instance_name = "east-server"
}

module "west_infra" {
  source = "./ec2_module"

  providers = {
    aws = aws.west
  }

  instance_name = "west-server"
}
```

* Child Module
```hcl
variable "instance_name" {}

resource "aws_instance" "example" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
```

---

* Root module
```hcl
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "platform" {
  source = "./platform_module"

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }
}
```

* Child Module
```hcl
resource "aws_eks_cluster" "example" {
  name = "demo-cluster"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
  }
}
```