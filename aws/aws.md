### References:-
- https://spacelift.io/blog/terraform-ec2-instance

---

```bash
aws configure

aws configure list

aws configure list --profile dev

aws configure list-profiles

aws configure --profile <profile-name>

aws configure set aws_access_key_id <KEY>

aws configure set aws_secret_access_key <SECRET>

aws configure set aws_session_token <TOKEN>

aws configure set default.region <REGION>

aws configure set default.output <FORMAT>

aws configure set aws_access_key_id <KEY> --profile <name>

aws configure set aws_secret_access_key <SECRET> --profile <name>

aws configure set region ap-south-1 --profile dev

aws configure set output json --profile prod

aws configure get region

aws configure get aws_access_key_id

aws configure get output

aws configure get region --profile dev

aws configure get aws_secret_access_key --profile dev

#AWS uses two files:
~/.aws/credentials
~/.aws/config

#To edit manually:
aws configure edit
aws configure edit --profile <profile>

#Configure SSO Login
aws configure sso
aws configure sso --profile <profile-name>

#Linux
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
export AWS_SESSION_TOKEN=xxxx
export AWS_DEFAULT_REGION=ap-south-1
export AWS_PROFILE=dev

#Windows
setx AWS_ACCESS_KEY_ID "xxxx"
setx AWS_SECRET_ACCESS_KEY "xxxx"
setx AWS_DEFAULT_REGION "ap-south-1"

#Configure MFA with aws sts
aws sts get-session-token --serial-number <ARN> --token-code <MFA_CODE>

aws configure set aws_access_key_id <temp_key> --profile mfa
aws configure set aws_secret_access_key <temp_secret> --profile mfa
aws configure set aws_session_token <session_token> --profile mfa

#Configure AWS Role Assumption
aws configure set role_arn arn:aws:iam::<ACCOUNT_ID>:role/<ROLE> --profile dev
aws configure set source_profile default --profile dev

#Configure AWS CLI to Use a Web Token (OIDC)
aws configure set web_identity_token_file /path/token.jwt --profile kube
aws configure set role_arn arn:aws:iam::<ACC>:role/<ROLE> --profile kube

#Configure Output Formatting
aws configure set output json
aws configure set output yaml
aws configure set output text

#Configure AWS CLI to Use a Proxy
aws configure set proxy.host proxy.example.com
aws configure set proxy.port 8080

#Clear Configuration Values
aws configure set aws_access_key_id "" --profile dev
aws configure set aws_secret_access_key "" --profile dev
```

* Terraform will work without AWS CLI also but AWS CLI make things easy it allow easy way to setup credentials.

```hcl
provider "aws" {
  region = "us-west-2"
  profile = "jack.roper"
}
```
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  profile = "tf-user"
}

resource "aws_instance" "example_server" {
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"

  tags = {
    Name = "JacksBlogExample"
  }
}
```

---
```bash
ssh-keygen -t rsa -b 4096
cat jack1.pub
```
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  profile = "jack.roper"
}

resource "aws_instance" "example_server" {
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"
  user_data = <<EOF
#!/bin/bash
echo "Copying the SSH Key to the server"
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT54B8Le3cQe6ufDHltjSfq/VU1beEy5B2uhVZOGWbOekBhItqEmY3FErYHJzlHRWKwiwuH43uLpSlo/mvhYm/sV2zDWU/Sqq5Th2m9pUYGg0daFUA/iK3wBfWIVJHe6KqIEmLjKyoN3i12nTACbpmSTb5qXEnp6DVvdgIh3Pa9ID/r+geEeS0YIEztmyVKa947bp64/+zKXznWxyYmQYDZkmbKi8JsMXLGTdemQp6QBIme6D3KTPkGIFyG2VECRBn1InruQHeG+kmKDIAzxBeOfGFmTSDyEA+cT4+DMyQtWwcMx1mc9UAmGVo6NEwY1Y/mBOLHwdjBCnJO4Eiis3eJYiA8n7+jIAJ66ANPVIfBYoQ6NoYi2+Ep3EvhDcTJbq2/WgsJTwFAd84F+42PNsltnkTIRsOdsJZtrhxh1dgV91Sk919d0oME0Gph4XHk9q1ddD1lXRPfsG9Ejq6i9GqTB+spk6PXWaC57Im++XL/w3FI/sNLCIVgtXZeeL/GktzDrhDI2s+81hYTcyaw5cfdEb4xULS0NxLVUklO907gQsw4zU0zHYJHwN/uhsEn2eIuqECTFrF5ZmoJyyRygz5ddUKO4qVmWCzqUD0FTQLmYlmG97TSIFmUzVMhH+ZWd2knqlBfSHBUq2tex7fYxRRT9jIGHIfTgAXtbiBkucjlQ== jackw@JAC10" >> /home/ubuntu/.ssh/authorized_keys
EOF

  tags = {
    Name = "JacksBlogExample"
  }
}
```

---
* Create a multiple EC2_Instance
* User loop --> `count` or `for_each`
  ```hcl
  resource "aws_instance" "example_server" {
    ami           = "ami-04e914639d0cca79a"
    instance_type = "t2.micro"
    count         = 10

    tags = {
      Name = "JacksBlogExample"
    }
  }
  ```

* `variable.tfvars`
  ```hcl
  configuration = [
    {
      "application_name" : "example_app_server-dev",
      "ami" : "ami-04e914639d0cca79a",
      "no_of_instances" : "10",
      "instance_type" : "t2.medium",
    },
    {
      "application_name" : "example_web_server-dev",
      "ami" : "ami-04e914639d0cca79a",
      "instance_type" : "t2.micro",
      "no_of_instances" : "5"
    },
    
  ]
  ```
* `main.tf`

  ```hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
      }
    }

    required_version = ">= 1.2.0"
  }

  provider "aws" {
    region  = "ap-south-1"
    profile = "tf-user"
  }

  variable "configuration" {
    description = "EC2 configuration"
    default = [{}]
  }

  locals {
    serverconfig = [
      for srv in var.configuration : [
        for i in range(1, srv.no_of_instances+1) : {
          instance_name = "${srv.application_name}-${i}"
          instance_type = srv.instance_type
          ami = srv.ami
        }
      ]
    ]
  }

  locals {
    instances = flatten(local.serverconfig)
  }

  output "demo1" {
    value = local.serverconfig
  }

  output "demo2" {
    value = local.instances
  }

  resource "aws_instance" "example_server" {
    for_each = {for server in local.instances: server.instance_name =>  server}

    ami           = each.value.ami
    instance_type = each.value.instance_type
    user_data = <<EOF
  #!/bin/bash
  echo "Copying the SSH Key to the server"
  echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT54B8Le3cQe6ufDHltjSfq/VU1beEy5B2uhVZOGWbOekBhItqEmY3FErYHJzlHRWKwiwuH43uLpSlo/mvhYm/sV2zDWU/Sqq5Th2m9pUYGg0daFUA/iK3wBfWIVJHe6KqIEmLjKyoN3i12nTACbpmSTb5qXEnp6DVvdgIh3Pa9ID/r+geEeS0YIEztmyVKa947bp64/+zKXznWxyYmQYDZkmbKi8JsMXLGTdemQp6QBIme6D3KTPkGIFyG2VECRBn1InruQHeG+kmKDIAzxBeOfGFmTSDyEA+cT4+DMyQtWwcMx1mc9UAmGVo6NEwY1Y/mBOLHwdjBCnJO4Eiis3eJYiA8n7+jIAJ66ANPVIfBYoQ6NoYi2+Ep3EvhDcTJbq2/WgsJTwFAd84F+42PNsltnkTIRsOdsJZtrhxh1dgV91Sk919d0oME0Gph4XHk9q1ddD1lXRPfsG9Ejq6i9GqTB+spk6PXWaC57Im++XL/w3FI/sNLCIVgtXZeeL/GktzDrhDI2s+81hYTcyaw5cfdEb4xULS0NxLVUklO907gQsw4zU0zHYJHwN/uhsEn2eIuqECTFrF5ZmoJyyRygz5ddUKO4qVmWCzqUD0FTQLmYlmG97TSIFmUzVMhH+ZWd2knqlBfSHBUq2tex7fYxRRT9jIGHIfTgAXtbiBkucjlQ== jackw@JAC10" >> /home/ubuntu/.ssh/authorized_keys
  EOF

    tags = {
      Name = "${each.key}"
    }
  }

  output "instances" {
    value       = "${aws_instance.example_server}"
    description = "EC2 details"
  }
  ```
  ```bash
  terraform.exe plan -var-file=dev.tfvars
  ```
  OUTPUT
  ```bash
    + demo1 = [
        + [
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-1"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-2"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-3"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-4"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-5"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-6"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-7"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-8"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-9"
                + instance_type = "t2.medium"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_app_server-dev-10"
                + instance_type = "t2.medium"
              },
          ],
        + [
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_web_server-dev-1"
                + instance_type = "t2.micro"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_web_server-dev-2"
                + instance_type = "t2.micro"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_web_server-dev-3"
                + instance_type = "t2.micro"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_web_server-dev-4"
                + instance_type = "t2.micro"
              },
            + {
                + ami           = "ami-04e914639d0cca79a"
                + instance_name = "example_web_server-dev-5"
                + instance_type = "t2.micro"
              },
          ],
      ]
    + demo2 = [
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-1"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-2"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-3"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-4"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-5"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-6"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-7"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-8"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-9"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_app_server-dev-10"
            + instance_type = "t2.medium"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_web_server-dev-1"
            + instance_type = "t2.micro"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_web_server-dev-2"
            + instance_type = "t2.micro"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_web_server-dev-3"
            + instance_type = "t2.micro"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_web_server-dev-4"
            + instance_type = "t2.micro"
          },
        + {
            + ami           = "ami-04e914639d0cca79a"
            + instance_name = "example_web_server-dev-5"
            + instance_type = "t2.micro"
          },
      ]
  ```

---
* `dev.tfvars`
  ```hcl
  configuration = {
    instance1 = {
      ami           = "ami-0123456789"
      instance_type = "t2.micro"
    }
    instance2 = {
      ami           = "ami-0987654321"
      instance_type = "t3.micro"
    }
  }
  ```
* `main.tf`
  ```hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
      }
    }

    required_version = ">= 1.2.0"
  }

  provider "aws" {
    region  = "ap-south-1"
    profile = "tf-user"
  }

  variable "configuration" {
    description = "EC2 configuration"
    type = map(object({
      ami           = string
      instance_type = string
    }))
  }

  locals {
    instances = [
      for name, cfg in var.configuration : {
        instance_name = name
        ami           = cfg.ami
        instance_type = cfg.instance_type
      }
    ]
  }

  resource "aws_instance" "example_server" {
    for_each = { for s in local.instances : s.instance_name => s }

    ami           = each.value.ami
    instance_type = each.value.instance_type

    tags = {
      Name = each.key
    }
  }
  ```

---
* How to Upload a Local File to an Amazon EC2 Instance Using Terraform
  * Terraform does not natively upload files to EC2 as part of resource creation.
  * However, you can do it using:
    * file provisioner (most common)
    * local-exec + scp (manual approach)
    * WinRM for Windows instances
  * Provisioners run after the EC2 instance is created.

* Upload File to Linux EC2 Instance (File Provisioner)
```hcl
resource "aws_instance" "linux_instance" {
  ami           = "ami-id"
  instance_type = "t2.micro"
  key_name      = "my-key"
  subnet_id     = "subnet-linux"
  security_groups = ["ssh"]

  provisioner "file" {
    source      = "local_file.txt"
    destination = "/home/ec2-user/remote_file.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/my-key.pem")
      host        = self.public_ip
    }
  }
}
```

* Upload File Using SCP (local-exec Provisioner)
```hcl
resource "aws_instance" "linux_instance" {
  ami             = "ami-id"
  instance_type   = "t2.micro"
  key_name        = "my-key"
  subnet_id       = "subnet-linux"
  security_groups = ["ssh"]

  provisioner "local-exec" {
    command = "scp -i ~/.ssh/my-key.pem local_file.txt ec2-user@${self.public_ip}:/home/ec2-user/remote_file.txt"
  }
}
```

* Upload File to Windows EC2 via WinRM
```hcl
resource "aws_instance" "windows_instance" {
  ami             = "ami-id"
  instance_type   = "t2.micro"
  key_name        = "my-key"
  subnet_id       = "subnet-windows"
  security_groups = ["winrm-access"]

  provisioner "file" {
    source      = "local_script.ps1"
    destination = "C:\\Users\\Administrator\\remote_script.ps1"

    connection {
      type     = "winrm"
      user     = "Administrator"
      password = "YourInstancePassword"
      host     = self.public_ip
    }
  }
}
```

---
* `install.sh`
  ```bash
  #!/bin/bash
  echo "Hello from install.sh" > /home/ec2-user/script-output.txt
  ```
* `main.tf`
  ```hcl
  provider "aws" {
    region = "ap-south-1"
  }

  resource "aws_instance" "example" {
    ami                    = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2023
    instance_type          = "t2.micro"
    key_name               = "my-key"

    # Runs automatically at boot
    user_data = file("${path.module}/install.sh")

    tags = {
      Name = "user-data-example"
    }
  }
  ```

---
* `local.txt`
  ```
  This file came from S3 via Terraform.
  ```
* `main.tf`
  ```hcl
  provider "aws" {
    region = "ap-south-1"
  }

  resource "aws_s3_bucket" "bucket" {
    bucket = "my-terraform-file-bucket-12345"
  }

  resource "aws_s3_object" "file" {
    bucket = aws_s3_bucket.bucket.bucket
    key    = "configs/locals.txt"
    source = "${path.module}/locals.txt"
    etag   = filemd5("${path.module}/locals.txt")
  }

  resource "aws_instance" "example" {
    ami           = "ami-0c2b8ca1dad447f8a"
    instance_type = "t2.micro"
    key_name      = "my-key"

    # EC2 downloads file from S3 when booting
    user_data = <<-EOF
      #!/bin/bash
      yum install -y awscli

      aws s3 cp s3://${aws_s3_bucket.bucket.bucket}/configs/locals.txt \
        /home/ec2-user/locals.txt

      echo "File downloaded from S3" > /home/ec2-user/done.log
    EOF

    iam_instance_profile = aws_iam_instance_profile.s3_profile.name

    tags = {
      Name = "s3-download-example"
    }
  }

  # IAM Role for EC2 to read from S3
  resource "aws_iam_role" "s3_role" {
    name = "ec2-s3-read-role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action = "sts:AssumeRole"
      }]
    })
  }

  resource "aws_iam_policy" "s3_read_policy" {
    name        = "EC2S3ReadPolicy"
    description = "Allow EC2 to read from S3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
      }]
    })
  }

  resource "aws_iam_role_policy_attachment" "attach" {
    role       = aws_iam_role.s3_role.name
    policy_arn = aws_iam_policy.s3_read_policy.arn
  }

  resource "aws_iam_instance_profile" "s3_profile" {
    name = "s3-instance-profile"
    role = aws_iam_role.s3_role.name
  }
  ```

---
* How to Use Terraform Modules to Deploy EC2 Instances (Full Guide)
  * Terraform modules help you reuse, standardize, and scale your infrastructure configuration.
  * We will create:
    * A module that deploys EC2 instances
    * A root configuration that calls the module
    * Examples of scaling up/down easily

```bash
ec2-module/
  main.tf
  variables.tf
  outputs.tf
```
```hcl
resource "aws_instance" "this" {
  for_each      = var.instances
  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  tags = merge(
    {
      Name = each.key
    },
    each.value.tags
  )
}
```
```hcl
variable "instances" {
  description = "Map of EC2 instances to create with their configurations"
  type = map(object({
    instance_type = string
    subnet_id     = string
    ami_id        = string
    tags          = map(string)
  }))
}

<!-- instances = {
  name = {
    instance_type = "...",
    subnet_id     = "...",
    ami_id        = "...",
    tags = { ... }
  }
} -->

```
```hcl
output "instances" {
  description = "Map of instance names to their IDs and private ips"
  value = {
    for name, inst in aws_instance.this :
    name => {
      id         = inst.id
      private_ip = inst.private_ip
    }
  }
}

<!-- {
  "web-1": {
    "id": "i-0a12345d",
    "private_ip": "10.0.2.123"
  }
} -->

```

* Use the Module in Your Root Configuration
```bash
root/
  main.tf
ec2-module/
  main.tf
  variables.tf
  outputs.tf
```
```hcl
module "ec2_instances" {
  source = "../ec2-module"

  instances = {
    web-1 = {
      instance_type = "t3.micro"
      subnet_id     = "subnet-12345678"
      ami_id        = "ami-0735c191cf914754d"
      tags = {
        env  = "dev"
        role = "web"
      }
    }
  }
}
```
```hcl
provider "aws" {
  region = "eu-west-1"
}

module "ec2_instances" {
  source = "../ec2-module"

  instances = {
    web-1 = {
      instance_type = "t3.micro"
      subnet_id     = "subnet-12345678"
      ami_id        = "ami-0735c191cf914754d"
      tags = {
        env  = "dev"
        role = "web"
      }
    }

    web-2 = {
      instance_type = "t3.micro"
      subnet_id     = "subnet-87654321"
      ami_id        = "ami-0735c191cf914754d"
      tags = {
        env  = "dev"
        role = "web"
      }
    }
  }
}
```

---

### HOW TO WORK WITH SSM

* Launch an EC2 Instance With SSM Support
* Modern Amazon Linux 2023, Amazon Linux 2, Ubuntu EC2 instances already include SSM Agent.
* Create IAM Role for SSM

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = "1.14.0"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "example" {
  ami           = "ami-0d176f79571d18a8f"  # Amazon Linux 2023
  instance_type = "t3.micro"
  subnet_id     = "subnet-0afd242d13b99110f"

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "ssm-demo"
  }
}
```

* Ensure EC2 Can Reach SSM
* You need outbound access:
* Option A (Public subnet)
  * Works automatically.
* Option B (Private subnet)
  * You need SSM VPC Endpoints:
    ```bash
    com.amazonaws.region.ssm
    com.amazonaws.region.ec2messages
    com.amazonaws.region.ssmmessages
    ```
* Terraform example (optional):
  ```hcl
  resource "aws_vpc_endpoint" "ssm" {
    vpc_id            = var.vpc_id
    service_name      = "com.amazonaws.ap-south-1.ssm"
    vpc_endpoint_type = "Interface"
    subnet_ids        = var.private_subnets
    security_group_ids = [aws_security_group.vpce.id]
  }
  ```
 
* Connect to EC2 Using SSM Session Manager
  * NO SSH
  * NO key-pair
  * NO port 22
  * NO public IP
  * Option A — Connect from AWS Console
    * AWS Console → EC2 → Instance → Connect → "Session Manager" → Start session
    * You get a full shell instantly.
  * Option B — Connect Using AWS CLI
    `aws ssm start-session --target i-0123456789abcdef0`
  * Run Commands Remotely (No SSH Required)
    SSM Run Command lets you run shell commands on any EC2.
    ```bash
    aws ssm send-command \
    --instance-ids "i-0123456789abcdef0" \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["sudo yum install -y httpd"]'
    ```
    SSM runs it remotely and logs output to CloudWatch (if enabled).

---
---

Below is the **complete, production-grade, AWS-recommended best practices guide** for securing EC2 instances created with Terraform.

This is much more detailed than the short summary you provided — and includes **specific Terraform guidance**, real configurations, and AWS architecture best practices.

---

### **BEST PRACTICES FOR SECURING EC2 INSTANCES (Terraform)**
* A secure EC2 deployment requires applying security **across layers**:
  * Network Security
  * Identity & Access Management
  * Data Protection
  * Observability & Logging
  * OS Hardening
  * Instance Lifecycle Safety
  * Metadata, Patching & Auto-Recovery
  * Terraform-specific Best Practices

**NETWORK SECURITY (Security Groups, Subnets, VPC)**
  * Use least-privilege ingress rules allow **only required traffic**, e.g:
    ```hcl
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["YOUR-OFFICE-IP/32"]
    }
    ```

  * Restrict outbound traffic
    * Default SG outbound = allow all → NOT good.
      ```hcl
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]  # internal only
      }
      ```

  * Place EC2 in private subnets
    * Public EC2 = high risk.
      ```hcl
      map_public_ip_on_launch = false
      ```
    * Use NAT Gateway for outbound access.


**ACCESS MANAGEMENT (SSM + IAM Role)**
* NEVER use SSH keys when possible
  * Use **AWS SSM Session Manager** for secure access.
    ```hcl
    resource "aws_iam_role" "ssm_role" {
      name = "ec2-ssm-role"
      assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
    }

    resource "aws_iam_role_policy_attachment" "ssm_attach" {
      role       = aws_iam_role.ssm_role.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    ```
  * Attach it to EC2:
    ```hcl
    iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
    ```

* Use IAM role instead of storing credentials
  * DO NOT store AWS keys on EC2
  * Give EC2 only required IAM permissions


**DATA PROTECTION (EBS Encryption + KMS)**
  * Encrypt EBS volumes automatically
    Terraform:
    ```hcl
    encrypted = true
    kms_key_id = aws_kms_key.ec2_key.arn
    ```
  
  * Enable KMS key rotation
    ```hcl
    enable_key_rotation = true
    ```

  * Enforce IMDSv2 (metadata hardening)
    ```hcl
    metadata_options {
      http_tokens = "required"
    }
    ```
    This blocks SSRF attacks.


**OBSERVABILITY (Monitoring & Logging)**
  * Install CloudWatch agent using user_data or SSM
    ```hcl
    user_data = <<EOF
    #!/bin/bash
    yum install -y amazon-cloudwatch-agent
    EOF
    ```

  * Enable detailed monitoring
    ```hcl
    monitoring = true
    ```

  * Capture system logs, auth logs, security logs
    * Use CloudWatch Logs or SSM.

**OS HARDENING**
  * Disable root login
  * Disable password authentication
  * Enforce SSH key login only (if using SSH)
  * Enable firewall (UFW / firewalld)
  * Remove unnecessary packages
  * Keep OS patched (via SSM Patch Manager)


**LIFECYCLE MANAGEMENT**
  * Use create-before-destroy to avoid downtime
    ```hcl
    lifecycle {
      create_before_destroy = true
    }
    ```
  
  * Tag everything for tracking
    ```hcl
    tags = {
      Owner      = "DevOps"
      Env        = "prod"
      ManagedBy  = "Terraform"
    }
    ```

  * Enable instance auto-recovery
    ```hcl
    resource "aws_cloudwatch_metric_alarm" "recovery" {
      alarm_name          = "EC2AutoRecover-${aws_instance.example.id}"
      metric_name         = "StatusCheckFailed_System"
      namespace           = "AWS/EC2"
      statistic           = "Minimum"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 1
      period              = 60
      evaluation_periods  = 2
      alarm_actions       = ["arn:aws:automate:REGION:ec2:recover"]
    }
    ```

* **Enforce IMDSv2**
  ```hcl
  metadata_options {
    http_tokens = "required"
  }
  ```

---

### EC2 + Classic LB

```bash
ssh-keygen -t rsa -b 4096 -f demo
```
```bash
#!/bin/bash

# Update packages
yum update -y

# Install Apache
yum install -y httpd
systemctl enable --now httpd

# Fetch IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 300")

# Fetch instance ID using IMDSv2
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
       http://169.254.169.254/latest/meta-data/instance-id)

# Write content to index.html
echo "Hello from Backend Instance-${INSTANCE_ID}" > /var/www/html/index.html
```
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

data "aws_region" "current" {}

# output "current_region" {
#   value = data.aws_region.current
# }

# + current_region = {
#     + description = "Asia Pacific (Mumbai)"
#     + endpoint    = "ec2.ap-south-1.amazonaws.com"
#     + id          = "ap-south-1"
#     + name        = "ap-south-1"
#   }


data "aws_vpc" "default_vpc" {
  default = true
}

# output "default_vpc" {
#   value = data.aws_vpc.default_vpc
# }

# output "default_vpc" {
#   value = data.aws_vpc.default_vpc.id
# }

# + default_vpc = {
#     + arn                                  = "<arn>"
#     + cidr_block                           = "<cidr_block>"
#     + cidr_block_associations              = [
#         + {
#             + association_id = "<association_id>"
#             + cidr_block     = "<cidr_block>"
#             + state          = "associated"
#           },
#       ]
#     + default                              = true
#     + dhcp_options_id                      = "<dhcp_options_id>"
#     + enable_dns_hostnames                 = true
#     + enable_dns_support                   = true
#     + enable_network_address_usage_metrics = false
#     + filter                               = null
#     + id                                   = "<vpc_id>"
#     + instance_tenancy                     = "default"
#     + ipv6_association_id                  = ""
#     + ipv6_cidr_block                      = ""
#     + main_route_table_id                  = "<main_route_table_id>"
#     + owner_id                             = "<owner_id>"
#     + state                                = null
#     + tags                                 = {}
#     + timeouts                             = null
#   }

data "aws_availability_zones" "AZs" {
  state = "available"
}

# output "AZs" {
#   value = data.aws_availability_zones.AZs.names
# }

locals {
  zones           = data.aws_availability_zones.AZs.names
  available_zones = [for zone in local.zones : zone if zone != "ap-south-1c"]
  no_of_instances = 3
  Environment     = "Testing"
  Application     = "DemoApp"
}

resource "aws_key_pair" "keys" {
  key_name   = "demo"
  public_key = file("${path.module}/demo.pub")
}


resource "aws_security_group" "instance_sg" {
  vpc_id = data.aws_vpc.default_vpc.id
  name   = "instance-sg"
  ingress {
    description = "instance-sg"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "instance-sg"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.classic_lb_sg.id]
  }
  ingress {
    description     = "instance-sg"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.classic_lb_sg.id]
  }
  egress {
    description = "instance-sg"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "classic_lb_sg" {
  vpc_id = data.aws_vpc.default_vpc.id
  name   = "classic_lb_sg"
  ingress {
    description = "classic_lb_sg"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "classic_lb_sg"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "classic_lb_sg"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output "demo" {
#   value = aws_security_group.instance_sg.id
# }

resource "aws_instance" "backend_instance" {
  count                       = local.no_of_instances
  ami                         = "ami-0d176f79571d18a8f"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.keys.key_name
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  availability_zone           = local.available_zones[count.index % length(local.available_zones)]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/demo")
    host        = self.public_ip
  }

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp3"
  }

  tags = {
    Name        = "Instance-${count.index}"
    ENV         = "Testing"
    Application = "DemoApp"
  }
}

# output "name" {
#   value = aws_instance.backend_instance[*].id
# }

# # Create a new load balancer
resource "aws_elb" "classic_lb" {
  name               = "classic-terraform-elb"
  availability_zones = data.aws_availability_zones.AZs.names

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 3
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 10
  }

  instances                   = aws_instance.backend_instance[*].id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = [aws_security_group.classic_lb_sg.id]
  tags = {
    Name = "classic-terraform-elb"
  }
}

output "classic_lb_endpoint" {
  value = aws_elb.classic_lb.dns_name
}
```

### EC2 + CLB + AUTO SCALING GROUP

```bash
ssh-keygen -t rsa -b 4096 -f demo
```
```bash
#!/bin/bash

# Update packages
yum update -y

# Install Apache
yum install -y httpd
systemctl enable --now httpd

# Fetch IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 300")

# Fetch instance ID using IMDSv2
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
       http://169.254.169.254/latest/meta-data/instance-id)

# Write content to index.html
echo "Hello from Backend Instance-${INSTANCE_ID}" > /var/www/html/index.html
```
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

data "aws_region" "current" {}

# output "current_region" {
#   value = data.aws_region.current
# }

# + current_region = {
#     + description = "Asia Pacific (Mumbai)"
#     + endpoint    = "ec2.ap-south-1.amazonaws.com"
#     + id          = "ap-south-1"
#     + name        = "ap-south-1"
#   }


data "aws_vpc" "default_vpc" {
  default = true
}

# output "default_vpc" {
#   value = data.aws_vpc.default_vpc
# }

# output "default_vpc" {
#   value = data.aws_vpc.default_vpc.id
# }

# + default_vpc = {
#     + arn                                  = "<arn>"
#     + cidr_block                           = "<cidr_block>"
#     + cidr_block_associations              = [
#         + {
#             + association_id = "<association_id>"
#             + cidr_block     = "<cidr_block>"
#             + state          = "associated"
#           },
#       ]
#     + default                              = true
#     + dhcp_options_id                      = "<dhcp_options_id>"
#     + enable_dns_hostnames                 = true
#     + enable_dns_support                   = true
#     + enable_network_address_usage_metrics = false
#     + filter                               = null
#     + id                                   = "<vpc_id>"
#     + instance_tenancy                     = "default"
#     + ipv6_association_id                  = ""
#     + ipv6_cidr_block                      = ""
#     + main_route_table_id                  = "<main_route_table_id>"
#     + owner_id                             = "<owner_id>"
#     + state                                = null
#     + tags                                 = {}
#     + timeouts                             = null
#   }

data "aws_availability_zones" "AZs" {
  state = "available"
}

# Fetch all subnets in the default VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.default_subnets.ids)
  id       = each.value
}

# output "subnet_ids1" {
#   value = data.aws_subnets.default_subnets
# }

# output "AZs" {
#   value = data.aws_availability_zones.AZs.names
# }

# Select only subnets in AZ ap-south-1a and ap-south-1b
locals {
  subnet_ids = [
    for id, subnet in data.aws_subnet.subnet_details :
    id
    if subnet.availability_zone == "ap-south-1a" ||
       subnet.availability_zone == "ap-south-1b"
  ]
  Environment     = "Testing"
  Application     = "DemoApp"
}


# -----------------------------
# Key Pair
# -----------------------------
resource "aws_key_pair" "keys" {
  key_name   = "demo"
  public_key = file("${path.module}/demo.pub")
}


# -----------------------------
# Security Groups
# -----------------------------
resource "aws_security_group" "classic_lb_sg" {
  vpc_id = data.aws_vpc.default_vpc.id
  name   = "classic_lb_sg"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_sg" {
  vpc_id = data.aws_vpc.default_vpc.id
  name   = "instance-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.classic_lb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.classic_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output "demo" {
#   value = aws_security_group.instance_sg.id
# }

# -----------------------------
# Launch Template
# -----------------------------
resource "aws_launch_template" "web_lt" {
  name          = "web-lt"
  image_id      = "ami-0d176f79571d18a8f"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.keys.key_name

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  user_data = filebase64("${path.module}/userdata.sh")

  tags = {
    Name        = "Instance-by-LT"
    ENV         = "Testing"
    Application = "DemoApp"
  }
}


output "subnet_ids" {
  value = local.subnet_ids
}

# -----------------------------
# Classic Load Balancer
# -----------------------------
resource "aws_elb" "classic_lb" {
  name   = "classic-terraform-elb"
  subnets = local.subnet_ids   # FIXED — use subnets, not AZs

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 3
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 10
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  security_groups = [aws_security_group.classic_lb_sg.id]

  tags = {
    Name = "classic-terraform-elb"
  }
}

output "classic_lb_endpoint" {
  value = aws_elb.classic_lb.dns_name
}

# -----------------------------
# Auto Scaling Group
# -----------------------------
resource "aws_autoscaling_group" "asg" {
  name                      = "web-asg"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"

  vpc_zone_identifier = local.subnet_ids   # FIXED — ASG must use subnets

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  load_balancers = [aws_elb.classic_lb.id]  # FIXED — ASG auto-registers instances

  tag {
    key                 = "Name"
    value               = "ASG-Web"
    propagate_at_launch = true
  }
}

# -----------------------------
# Target Tracking Policy
# -----------------------------
resource "aws_autoscaling_policy" "scale_adjust_policy" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
  }
}

# -----------------------------
# Sticky Session (optional)
# -----------------------------
resource "aws_lb_cookie_stickiness_policy" "stickiness" {
  name                     = "sticky-policy"
  load_balancer            = aws_elb.classic_lb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}
```