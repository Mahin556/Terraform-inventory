
# https://spacelift.io/blog/how-to-use-terraform-variables#variable-substitution-using-cli-and-tfvars
# terraform plan -var "ami=test" -var "type=t2.nano" -var "tags={\"name\":\"My Virtual Machine\",\"env\":\"Dev\"}"

# terraform plan -var-file values.tfvars

# However, if you do not wish to provide the file path every time you run plan or apply, simply name the file as <filename>.auto.tfvars. This file is then automatically chosen to supply input variable values.

