```hcl
resource "aws_instance" "web" {
  ami                         = data.aws_ami.example.id
  instance_type               = ""
  vpc_security_group_ids      = [aws_security_group.sg1.id]
  associate_public_ip_address = true
  availability_zone           = var.az
  subnet_id                   = element([for x in aws_aws_subnet.name : x.id], 0)
  tags = {
    Name = "web"
  }
  key_name = "demo"
}
```