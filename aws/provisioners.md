* Using terraform we can create a infrastructure on a cloud provider.
* This infra server some purpose this can be hosting a backend login, frontend, database etc.
* This is not part of infrastructure provisioning but actually part of configuration management.
* But terraform allow to configure a infra like EC2 using terraform provisioners.
* Using provisioner we can run commands/scripts or perform file operations on local or remote machine.
* They can also transfer file from local machine to remote machine.
* There are three available provisioners: file (used for copying), local-exec (used for local operations), remote-exec (used for remote operations). 
* The file and remote-exec provisioners need a connection block to be able to do the remote operations.
* These connections help Terraform log into the newly created instance and perform these operations.
* Hashicorp suggests Terraform provisioners should only be considered when there is no other option. 

```hcl
resource "aws_instance" "name" {
  ami                    = "ami-0521bc4c70257a054"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.keys.key_name
  vpc_security_group_ids = [aws_security_group.name.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/demo")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
        "sudo yum install httpd -y",
        "sudo systemctl start httpd",
        "curl -s http://169.254.169.254/latest/meta-data/instance-type > instance_type.txt"
     ]
  }

  provisioner "file" {
    source = "./demo.pub"
    destination = "./.ssh/"
    connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/demo")
    host        = self.public_ip
  }
  }
  #sending folder
  provisioner "file" {
    source = "../user"
    destination = "/tmp/users"
  }

  provisioner "local-exec" {
    when = create
    command = "scp -i ${path.module}/demo ec2-user@${self.public_ip}:./instance_type.txt ./"
  }
}
```

---

```hcl
resource "null_resource" "example" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'This is a local command'"
  }
}
```