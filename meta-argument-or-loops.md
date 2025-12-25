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
  region = var.region
}

locals {
  project_name = "project1"
}

variable "region" {
    description = "value of the region"
    type = string
    default = "ap-south-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "${local.project_name}-vpc"
    PROJECT = local.project_name
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count      = 2
  tags = {
    Name    = "${local.project_name}-subnet-${count.index + 1}"
    PROJECT = local.project_name
  }
}

output "subnet_id-1" {
  value = aws_subnet.main[0].id
}

output "subnet_id-2" {
  value = aws_subnet.main[1].id
}

resource "aws_instance" "main" {
  ami           = "ami-0521bc4c70257a054"
  instance_type = "t2.micro"
  count         = 4
#   subnet_id     = element(aws_subnet.main[*].id, count.index % 2) #static
  subnet_id     = element(aws_subnet.main[*].id, count.index % length(aws_subnet.main)) #dynamic(subnets)
  #0%2=0
  #1%2=1
  #2%2=0
  #3%2=1
  
  tags = {
    Name    = "${local.project_name}-instance-${count.index + 1}"
    PROJECT = local.project_name
  }
}
```

---

```hcl
terraform {
  required_version = "1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  project_name = "project1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "${local.project_name}-vpc"
    PROJECT = local.project_name
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count      = 2
  tags = {
    Name    = "${local.project_name}-subnet-${count.index + 1}"
    PROJECT = local.project_name
  }
}

resource "aws_instance" "main" {
  ami           = var.ec2_config[count.index].ami
  instance_type = var.ec2_config[count.index].instance_type
  count         = length(var.ec2_config)
# subnet_id     = aws_subnet.main[0].id #static
# subnet_id = element(aws_subnet.main[*].id,count.index) #also work but when subnet and instance count same
  subnet_id     = element(aws_subnet.main[*].id, count.index % length(aws_subnet.main)) #dynamic(subnets)
  #0%2=0
  #1%2=1
  
  tags = {
    Name    = "${local.project_name}-instance-${count.index + 1}"
    PROJECT = local.project_name
  }
}
```
```hcl
variable "region" {
    description = "value of the region"
    type = string
    default = "ap-south-1"
}

variable "ec2_config" {
    type = list(object({
        ami = string
        instance_type = string
    }))
}
```
```hcl
ec2_config = [ 
  {
    ami = "ami-0f918f7e67a3323f0" #ubuntu
    instance_type = "t2.micro"
  },
  {
    ami = "ami-0d03cb826412c6b0f" #amazon
    instance_type = "t2.micro"
  } 
]
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
}

provider "aws" {
  region = var.region
}

locals {
  project_name = "project1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "${local.project_name}-vpc"
    PROJECT = local.project_name
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count      = 2
  tags = {
    Name    = "${local.project_name}-subnet-${count.index + 1}"
    PROJECT = local.project_name
  }
}

resource "aws_instance" "main" {
  for_each = var.ec2_map
  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id     = element(aws_subnet.main[*].id,index(keys(var.ec2_map),each.key) % length(aws_subnet.main))
  #0%2=0
  #1%2=1
  
  tags = {
    Name    = "${local.project_name}-instance-${each.key}"
    PROJECT = local.project_name
  }
}
```
```hcl
variable "region" {
    description = "value of the region"
    type = string
    default = "ap-south-1"
}

variable "ec2_config" {
    type = list(object({
        ami = string
        instance_type = string
    }))
}

variable "ec2_map" {
    type = map(object({
      ami = string
      instance_type = string
    }))
}
```
```hcl
ec2_config = [ {
  ami = "ami-0f918f7e67a3323f0" #ubuntu
  instance_type = "t2.micro"
},{
    ami = "ami-0d03cb826412c6b0f" #amazon
    instance_type = "t2.micro"
} ]

ec2_map = {
  "ubuntu" = {
    ami = "ami-0f918f7e67a3323f0" #ubuntu
    instance_type = "t2.micro"
  },
  "amazon" = {
    ami = "ami-0d03cb826412c6b0f" #amazon
    instance_type = "t2.micro"
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
}

provider "aws" {
  region = var.region
}

locals {
  PROJECT = "project1"
  ENV     = "PROD"
  subnets = flatten([aws_subnet.public, aws_subnet.private])
  subnet_name = [
    for subnet in local.subnets:
    subnet["tags"]["Name"]
  ]
}

variable "region" {
  description = "value of the region"
  type        = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

resource "aws_vpc" "project1-vpc" {
  cidr_block = "172.32.0.0/16"
  tags = {
    Name = "${local.PROJECT}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.project1-vpc.id
  cidr_block = "172.32.${count.index}.0/24"
  count      = 2
  tags = {
    Name    = "Public-subnet-${count.index + 1}"
    PROJECT = local.PROJECT
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.project1-vpc.id
  cidr_block = "172.32.${count.index + 2}.0/24"
  count      = 2
  tags = {
    Name    = "Private-subnet-${count.index + 3}"
    PROJECT = local.PROJECT
  }
}

resource "aws_instance" "instances" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(local.subnets)
  subnet_id     = local.subnets[count.index].id
  tags = {
    Name    = startswith(local.subnet_name[count.index], "Public") ? "Public-Instance-${count.index}" : "Private-Instance-${count.index}"
    PROJECT = local.PROJECT
  }
}

output "public_subnet_names" {
  value = [
    for subnet in aws_subnet.public :
    subnet.tags["Name"]
  ]
}

output "public_subnet_ids" {
  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}

output "private_subnet_names" {
  value = [
    for subnet in aws_subnet.private :
    subnet.tags["Name"]
  ]
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "demo" {
  value = local.subnets
}

output "instance_ids" {
  value = aws_instance.instances[*].id
}

output "instance_dns" {
  value = aws_instance.instances[*].private_dns
}
```
```hcl
region        = "ap-south-1"
ami           = "ami-0a1235697f4afa8a4"
instance_type = "t2.micro"
```