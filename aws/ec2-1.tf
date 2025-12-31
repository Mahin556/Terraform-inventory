#ssh-keygen -t rsa -b 4096
#cat jack1.pub

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