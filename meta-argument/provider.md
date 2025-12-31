* Provider is a Terraform meta-argument.
* It is used inside a resource block.
* It tells Terraform which exact provider configuration to use for that single resource.
* “The provider meta-argument is used at the resource level to explicitly bind a resource to a specific provider configuration.”

* Terraform behavior by default:
    * If you define one provider, all resources use it.
    * If you define multiple providers (aliases), Terraform needs to know:
        * Which resource should use which provider.
        * That decision is made using the provider meta-argument.
        * `provider` overrides the default provider, override applies only to that resource that define the `provider` into there config.

* Why provider exists (real-world reasons)
    * Same cloud, different regions
    * Same cloud, different accounts
    * Same cloud, different IAM credentials
    * Cross-region or cross-account architectures

* Without provider:
    * Terraform would not know where to create the resource
    * Plan/apply would fail with ambiguity errors


```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

resource "aws_instance" "east_instance" {
  ami           = "ami-111111"
  instance_type = "t2.micro"
}

resource "aws_instance" "west_instance" {
  provider      = aws.west
  ami           = "ami-222222"
  instance_type = "t2.micro"
}
```

* What happens internally (BTS)
    * Terraform loads two AWS provider instances
        * `aws (us-east-1)`
        * `aws.west (us-west-1)`
    * Each provider has:
        * its own region
        * its own credentials
    * The resource block explicitly binds:
        * `east_instance` → default aws
        * `west_instance` → aws.west
    * This mapping is written into `terraform.tfstate`

