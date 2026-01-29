```hcl
variable "session_token" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "username" {
  type = string
}

resource "null_resource" "demo" {
  provisioner "local-exec" {
    command = "echo User=${var.username}, Token=${var.session_token}"
  }
}

output "show_user" {
  value = var.username
}
output "show_token" {
  value = var.session_token
}
```
```bash
terraform init
terraform apply -var="username=mahindev" -var="session_token=abc123"

cat terraform.tfstate | grep abc123
cat terraform.tfstate | grep mahindev
```