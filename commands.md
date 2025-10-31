```bash
terraform version

Terraform v1.12.2
on windows_amd64

Your version of Terraform is out of date! The latest version
is 1.13.4. You can update by downloading from https://developer.hashicorp.com/terraform/install

terraform --version
terraform -v
```
```bash
terraform -h
terraform -help
terraform --help
```
```bash
terraform init #Run in the project directory, download provider plugins

terraform plan

terraform apply #Give plan,review plan, approve(yes)

terraform destroy #Remove resource created by terraform, all reources in cofiguration

terraform validate

terraform providers	#Lists all providers used in the configuration.
terraform providers mirror <dir>	#Downloads providers locally for offline installation.
terraform init -upgrade	#Updates all provider plugins to the latest allowed versions.
terraform state list	#Lists all managed resources by provider.
```