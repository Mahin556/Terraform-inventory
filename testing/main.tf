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