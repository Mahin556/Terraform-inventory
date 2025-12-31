* Allow to create multiple resource or use same config to work with multiple resource.

```hcl
resource "aws_instance" "ec2" {
  count                = 4
  ami                  = ## ami-2345rtfv23f
  subnet_id            = ## subnet-234r5t
  instance_type        = ## t3a.medium
  
  root_block_device {
    volume_size = ## 10
    volume_type = ## "gp3"
  }
  tags = {
    Name = "Instance-${count.index}"
    Env  = ## "dev"
  }
}
```