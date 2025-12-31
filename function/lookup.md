```hcl
variable "userage" {
    type = map
    default = {
        mahin = 22
        raza = 20
    }
}

variable "username" {
    type = string
}

output "age" {
  value = "User's age it ${var.userage.mahin}"
}

output "age1" {
  value = "${var.username} age it ${lookup(var.userage,var.username)}"
}
```
```hcl
resource "aws_instance" "app" {
  ami                         = data.aws_ami.example.id
  instance_type               = ""
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  associate_public_ip_address = false
  availability_zone           = var.az
  subnet_id                   = lookup({ for x, y in aws_aws_subnet.name : x => y.id }, "subnet2")
  tags = {
    Name = "app"
  }
  key_name = "demo"
}
```