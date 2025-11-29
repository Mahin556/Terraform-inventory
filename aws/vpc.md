```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = "~> 1.12.0"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
    ENV = "PROD"
}
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "public_subnet"
        ENV = "PROD"
    }    
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    tags = {
        Name = "private_subnet"
        ENV = "PROD"
    }    
}

resource "aws_internet_gateway" "igw-1" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name = "igw-1"
        ENV = "PROD"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name = "public_route_table"
        ENV = "PROD"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-1.id
    }
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

# Security Group for nginx-server
resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name    = "my-sg"
        ENV = "PROD"
    }

    #Inbound Rules
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #outbound rules
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```

---

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
  backend "s3" {
    bucket = "mahin-bucket-1cb92966a8b31355b1a8bd48"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "az" {
  state = "available"
}


resource "aws_vpc" "name" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myvpc"
    ENV  = "dev"
  }
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "mysg"
    ENV  = "dev"
  }

  dynamic "ingress" {
    for_each = [22,80,443]
    iterator = port
    content {
        from_port   = port.value
        to_port     = port.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.az.names[0]  # First AZ
  tags = {
    Name = "subnet1"
    ENV  = "dev"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.name.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.az.names[1]  # Second AZ
  tags = {
    Name = "subnet2"
    ENV  = "dev"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "igw"
    ENV  = "dev"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "myrt"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "rt-associate-1" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "rt-associate-2" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet2.id
}

resource "aws_key_pair" "keys" {
  key_name = "public_key"
  public_key = file("${path.module}/id_dsa.pub")
}

output "keyname" {
  value = aws_key_pair.keys.key_name
}

resource "aws_instance" "nginxserver" {
  ami = data.aws_ami.ami_id.id
  tags = {
    Name = "nginx-server"
  }
  subnet_id                   = aws_subnet.subnet1.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.keys.key_name
#   key_name = "public_key"
#   user_data                   = <<-EOF
#             #!/bin/bash
#             sudo yum install httpd -y
#             sudo systemctl start httpd
#             echo -e "Hostname:- $(hostname)\nIP-Address:- $(hostname -I)" > /var/www/html/index.html
#             EOF
    user_data = file("${path.module}/user_data.sh")
}

output "instance_ip" {
  value = aws_instance.nginxserver.public_ip
}
output "instance_dns" {
  value = aws_instance.nginxserver.public_dns
}
output "instance_url" {
  value = "http://${aws_instance.nginxserver.public_dns}"
}
```

---

### VPC + PUBLIC AND PRIVATE SUBNET + INTERNET GATEWAY + NAT INSTANCE + ROUTE TABLE

(https://dev.to/marocz/in-depth-guide-setting-up-a-nat-gateway-in-aws-using-cloudformation-5c54)
(https://levelup.gitconnected.com/aws-nat-instances-explained-secure-internet-access-for-private-subnets-634aee50f97a)

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myvpc"
    ENV  = "dev"
  }
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "mysg"
    ENV  = "dev"
  }

  dynamic "ingress" {
    for_each = [22,80,443]
    iterator = port
    content {
        from_port   = port.value
        to_port     = port.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[0]  # First AZ
  tags = {
    Name = "public-subnet"
    ENV  = "dev"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.az.names[1]  # Second AZ
  tags = {
    Name = "private-subnet"
    ENV  = "dev"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
    ENV  = "dev"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet.id   # MUST be PUBLIC subnet

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "myrt-public"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "myrt-private"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "rt-associate-1" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_route_table_association" "rt-associate-2" {
  route_table_id = aws_route_table.private_subnet_route_table.id
  subnet_id      = aws_subnet.private-subnet.id
}

resource "aws_key_pair" "keys" {
  key_name = "public_key"
  public_key = file("${path.module}/rsa.pub")
}

resource "aws_instance" "public_nginxserver" {
  ami = data.aws_ami.ami_id.id
  tags = {
    Name = "nginx-server"
  }
  subnet_id                   = aws_subnet.public-subnet.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.keys.key_name
#   key_name = "public_key"
#   user_data                   = <<-EOF
#             #!/bin/bash
#             sudo yum install httpd -y
#             sudo systemctl start httpd
#             echo -e "Hostname:- $(hostname)\nIP-Address:- $(hostname -I)" > /var/www/html/index.html
#             EOF
    user_data = file("${path.module}/userdata.sh")
}

resource "aws_instance" "private_nginxserver" {
  ami = data.aws_ami.ami_id.id
  tags = {
    Name = "nginx-server"
  }
  subnet_id                   = aws_subnet.private-subnet.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true #for production keep it false
  key_name = aws_key_pair.keys.key_name
#   key_name = "public_key"
#   user_data                   = <<-EOF
#             #!/bin/bash
#             sudo yum install httpd -y
#             sudo systemctl start httpd
#             echo -e "Hostname:- $(hostname)\nIP-Address:- $(hostname -I)" > /var/www/html/index.html
#             EOF
    user_data = file("${path.module}/userdata.sh")
}

```

---

### EC2 Server + EC2 BASTION HOST + VPC + SUBNETs + IGW + NAT GATEWAY + SG + KEY

* VPC
* Public + Private subnet
* IGW + NGW
* Route table 1 --> IGW ---> Public subnet
* Route table 2 --> NGW ---> Private subnet
* SG1 --> bastion host
* SG2 --> Private instance
* KEY ---> both bastion + private instance
* Save private key at bastion host with right permissions
* Bastion host ---> public subnet
* Private instance ---> private subnet
* Output bastion host ssh hrl

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "my_vpc"
    ENV  = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = data.aws_availability_zones.az.names[0]  # First AZ
  tags = {
    Name = "public_subnet"
    ENV  = "dev"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = data.aws_availability_zones.az.names[1]  # Second AZ
  tags = {
    Name = "private_subnet"
    ENV  = "dev"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
    ENV  = "dev"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id   # MUST be PUBLIC subnet

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "myrt-public"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "myrt-private"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "rt-associate-1" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table_association" "rt-associate-2" {
  route_table_id = aws_route_table.private_subnet_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "aws_key_pair" "keys" {
  key_name = "public_key"
  public_key = file("${path.module}/rsa.pub")
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "bastion_sg"
    ENV  = "dev"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_private_ip" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "allow_private_ip_sg"
    ENV  = "dev"
  }

  ingress {
    description              = "Allow SSH from Bastion SG"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    security_groups          = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.keys.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion_host"
    ENV  = "dev"
  }

  # ---------------------
  # Copy private key file
  # ---------------------
  provisioner "file" {
    source      = "${path.module}/rsa"
    destination = "/home/ec2-user/.ssh/rsa"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/rsa")
      host        = self.public_ip
    }
  }

  # ---------------------
  # Fix permissions & export private IP
  # ---------------------
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/rsa",
      "echo 'export PRIVATE_INSTANCE_IP=${aws_instance.private_instance.private_ip}' >> ~/.bashrc"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/rsa")
      host        = self.public_ip
    }
  }
}


resource "aws_instance" "private_instance" {
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = aws_key_pair.keys.key_name
  vpc_security_group_ids      = [aws_security_group.allow_private_ip.id]
  associate_public_ip_address = false
  tags = {
    Name = "bastion_host"
    ENV  = "dev"
  }
}

output "bastion_public_ip" {
  value = "ssh -i ./rsa ec2-user@${aws_instance.bastion.public_ip}"
}
output "private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}
```

---

### EC2 Server + EC2 BASTION HOST + VPC + SUBNETs + IGW + NAT INSTANCE + SG + KEY

(https://docs.aws.amazon.com/vpc/latest/userguide/work-with-nat-instances.html#create-nat-ami)
(https://pabis.eu/blog/2025-06-03-AWS-NAT-Instance-from-scratch-simplified.html)

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

data "aws_ami" "ami_id" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_ami" "nat_ami" {
  most_recent = true
  owners      = ["710464970777"]

  filter {
    name   = "name"
    values = ["amzn-lnx2-hvm-nat-java-*"]
  }
}



data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "my_vpc"
    ENV  = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = data.aws_availability_zones.az.names[0]  # First AZ
  tags = {
    Name = "public_subnet"
    ENV  = "dev"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = data.aws_availability_zones.az.names[1]  # Second AZ
  tags = {
    Name = "private_subnet"
    ENV  = "dev"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
    ENV  = "dev"
  }
}

resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "myrt-public"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "myrt-private"
    ENV  = "dev"
  }
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }
}

resource "aws_route_table_association" "rt-associate-1" {
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table_association" "rt-associate-2" {
  route_table_id = aws_route_table.private_subnet_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

resource "aws_key_pair" "keys" {
  key_name = "public_key"
  public_key = file("${path.module}/rsa.pub")
}

resource "aws_security_group" "nat_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow traffic from private subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat_sg"
  }
}


resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "bastion_sg"
    ENV  = "dev"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_private_ip" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "allow_private_ip_sg"
    ENV  = "dev"
  }

  ingress {
    description              = "Allow SSH from Bastion SG"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    security_groups          = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#NAT Instance MUST be in Public Subnet = 0.0.0.0/0 → Internet Gateway
#NAT instance MUST have a public IP = associate_public_ip_address = true
#NAT instance MUST have Source/Destination Check disabled = source_dest_check = false
#Use AMI that have IP Forwarding and iptables masquerading (NAT routing) enabled
resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.nat_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  source_dest_check           = false

  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  tags = {
    Name = "nat-instance"
  }
}

resource "aws_eip" "lb" {
  domain = "vpc"
  tags = {
    Name = "eip_for_nat"
    ENV  = "dev"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.lb.id
}

# resource "aws_instance" "nat_instance" {
#   ami           = data.aws_ami.ami_id.id
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public_subnet.id
#   key_name      = aws_key_pair.keys.key_name
#   source_dest_check = false

#   user_data = <<EOF
# #!/bin/bash
# set -e

# echo "[+] Installing iptables-services"
# yum install -y iptables-services

# echo "[+] Enabling and starting iptables service"
# systemctl enable iptables
# systemctl start iptables

# echo "[+] Enabling IP forwarding persistently"
# cat <<EOT >/etc/sysctl.d/custom-ip-forwarding.conf
# net.ipv4.ip_forward=1
# EOT

# sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

# echo "[+] Detecting primary network interface"
# PRIMARY_IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

# echo "[+] Primary interface detected: $PRIMARY_IFACE"

# echo "[+] Configuring NAT masquerading"
# iptables -t nat -A POSTROUTING -o "$PRIMARY_IFACE" -j MASQUERADE
# iptables -F FORWARD

# echo "[+] Saving iptables config"
# service iptables save

# echo "[+] NAT setup completed successfully"
# EOF

#   tags = {
#     Name = "nat_instance"
#     ENV  = "dev"
#   }
# }



resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.keys.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion_host"
    ENV  = "dev"
  }

  # ---------------------
  # Copy private key file
  # ---------------------
  provisioner "file" {
    source      = "${path.module}/rsa"
    destination = "/home/ec2-user/.ssh/rsa"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/rsa")
      host        = self.public_ip
    }
  }

  # ---------------------
  # Fix permissions & export private IP
  # ---------------------
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/rsa",
      "echo 'export PRIVATE_INSTANCE_IP=${aws_instance.private_instance.private_ip}' >> ~/.bashrc"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/rsa")
      host        = self.public_ip
    }
  }
}


resource "aws_instance" "private_instance" {
  ami                         = data.aws_ami.ami_id.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = aws_key_pair.keys.key_name
  vpc_security_group_ids      = [aws_security_group.allow_private_ip.id]
  associate_public_ip_address = false
  tags = {
    Name = "private_instance"
    ENV  = "dev"
  }
}

output "bastion_public_ip" {
  value = "ssh -i ./rsa ec2-user@${aws_instance.bastion.public_ip}"
}

output "private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}

output "connect_to_private_instance" {
  value = "ssh -i ./.ssh/rsa ec2-user@$PRIVATE_INSTANCE_IP"
}
```

---

### NACL

* A stateless firewall applied at the subnet level.
* Every subnet in a VPC must be associated with exactly one NACL.
* If you don’t create one → the subnet uses the default NACL (allow all inbound/outbound).
* Stateless = return traffic must be manually allowed.
* Rules are evaluated by rule number order (lowest → highest).
* NACL applies on both:
    * Inbound traffic to subnet
    * Outbound traffic from subnet

```hcl
resource "aws_network_acl" { ... }
resource "aws_network_acl_rule" { ... }
resource "aws_subnet_network_acl_association" { ... }
```

* Public Subnet NACL

```hcl
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc.id

  subnet_ids = [
    aws_subnet.public_subnet.id
  ]

  tags = {
    Name = "public-nacl"
  }

  # Allow HTTP Inbound
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow HTTPS Inbound
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow SSH only from my IP
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "YOUR_IP/32"
    from_port  = 22
    to_port    = 22
  }

  # Allow Ephemeral Outbound (1024–65535)
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow all outbound ICMP (ping response)
  egress {
    rule_no    = 110
    protocol   = "icmp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = -1
    to_port    = -1
  }
}
```

* Private Subnet (Private EC2 via NAT)

```hcl
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id

  subnet_ids = [
    aws_subnet.private_subnet.id
  ]

  tags = {
    Name = "private-nacl"
  }

  # Allow outbound access to internet (via NAT)
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow return traffic from NAT (ephemeral inbound)
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Allow outbound DNS
  egress {
    rule_no    = 120
    protocol   = "udp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }

  # Allow inbound DNS responses
  ingress {
    rule_no    = 120
    protocol   = "udp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }
}
```

* `aws_network_acl_rule` (Modular Method)

```hcl
resource "aws_network_acl" "my_acl" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-acl"
  }
}

resource "aws_network_acl_rule" "inbound_ssh" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "out_ephemeral" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
```

* Associate a NACL with SUBNET

```hcl
resource "aws_subnet_network_acl_association" "assoc" {
  subnet_id       = aws_subnet.public_subnet.id
  network_acl_id  = aws_network_acl.my_acl.id
}
```

---

### Interfaces

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "tf-user"
}

data "aws_availability_zones" "AZs" {
  state = "available"
}


locals {
  availability_zones = data.aws_availability_zones.AZs.names
  available_zones    = [
    for az in local.availability_zones : az
    if substr(az, length(az)-1, 1) != "c"
  ]
  #letters = [for az in local.azs : substr(az, -1, 1)]
}


# output "name" {
#   value = local.available_zones
# }

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

# Create Public Subnets in the each available AZs
resource "aws_subnet" "my_public_subnet" {
  for_each = { for idx, az in local.available_zones : idx => az }
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.${each.key}.0/24"
  availability_zone = each.value
  tags = {
    Name = "tf-public-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "tf-igw"
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "tf-public-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.my_public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.my_public_rt.id
}

#Root cause: AWS reserves the first four and the last IP in every subnet CIDR, so you tried to create a network interface with a private IP that sits inside that reserved range.
#Example for 10.0.0.0/24:
#reserved: 10.0.0.0, 10.0.0.1, 10.0.0.2, 10.0.0.3, 10.0.0.255
#usable: 10.0.0.4 → 10.0.0.254
resource "aws_network_interface" "interface_1" {
  subnet_id       = aws_subnet.my_public_subnet[0].id
  private_ips    = ["10.0.0.4"]
  security_groups = [aws_security_group.sg.id]
}

resource "aws_network_interface" "interface_2" {
  subnet_id       = aws_subnet.my_public_subnet[1].id
  private_ips    = ["10.0.1.4"]
}

resource "aws_security_group" "sg" {
  name        = "tf-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "demo-key" {
  key_name   = "demo-key"
  public_key = file("${path.module}/rsa.pub") 
}

resource "aws_instance" "instance" {
  ami = "ami-0d176f79571d18a8f" # Amazon Linux 2 AMI (HVM), SSD Volume Type in ap-south-1
  instance_type = "t2.micro"
  key_name = aws_key_pair.demo-key.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  availability_zone = local.available_zones[0]
  subnet_id = aws_subnet.my_public_subnet[0].id
  associate_public_ip_address = true
  # network_interface {
  #   network_interface_id = aws_network_interface.interface_1.id
  #   device_index         = 0
  # }
  #We can not attach netwo
  # network_interface {
  #   network_interface_id = aws_network_interface.interface_2.id
  #   device_index = 1
  # }
  tags = {
    Name = "tf-ec2-instance"
  }
}

resource "aws_network_interface_attachment" "attachement_1" {
  network_interface_id = aws_network_interface.interface_1.id
  instance_id = aws_instance.instance.id
  device_index = 1
}

# resource "aws_network_interface_attachment" "attachement_2" {
#   network_interface_id = aws_network_interface.interface_2.id
#   instance_id = aws_instance.instance.id
#   device_index = 1
# }
```