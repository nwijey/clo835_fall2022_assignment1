
#----------------------------------------------------------
# CLO835 - Assignment 1
#
# Build EC2 Instances
#
#----------------------------------------------------------

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Data block to retrieve the default VPC id
data "aws_vpc" "default" {
  default = true
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}


# Reference subnet provisioned by 01-Networking 
resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/install_docker.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Amazon-Linux"
    }
  )
}


# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "allow_ssh_http"
  description = "Allow SSH and http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
   ingress {
    description      = "Allow HTTP for Blue"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow HTTP for Pink"
    from_port        = 8082
    to_port          = 8082
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "Allow HTTP for Lime"
    from_port        = 8083
    to_port          = 8083
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }  


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

# Elastic IP
resource "aws_eip" "static_eip" {
  instance = aws_instance.my_amazon.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}

# ECR repositories
resource "aws_ecr_repository" "clo835-assignment1-app" {
  name                 = "clo835-assignment1-app"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "clo835-assignment1-db" {
  name                 = "clo835-assignment1-db"
  image_tag_mutability = "MUTABLE"
}


/*
# Load balancer
resource "aws_lb" "alb" {
#  for_each = var.ports
  name               = "alb-${var.env}"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
#  security_groups    = [aws_security_group.my_sg.id]
  subnets            = aws_subnet.public_subnet.id[*]
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-ALB"
    }
  )
}

resource "aws_lb_listener" "alb_listener" {
  for_each = var.ports
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
 # for_each = var.ports
  name        = "tg-alb-${var.env}"
  port        = 8081
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  depends_on = [
    aws_lb.alb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "container" {
 # for_each = var.ports
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.my_amazon.id
  port             = 8081
}*/