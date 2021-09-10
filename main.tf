terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.15.1"
}

variable "ami_id" {
  type = string
}

variable "data_volumes" {
  type = list(object({
    ebs_volume_id = string
    availability_zone = string
  }))
  description = "List of EBS volumes"
  default = []
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#resource "aws_instance" "todoapp" {
#  key_name        = resource.aws_key_pair.deployer-key.key_name
#  security_groups = [aws_security_group.custom-instance-security-group.id]
#  ami             = var.ami_id
#  instance_type   = "t2.micro"
#
#  tags = {
#    Name = "TODO_APP_INSTANCE"
#  }
#}

resource "aws_key_pair" "deployer-key" {
  key_name   = "deployer-key"
  public_key = file(".ssh/id_rsa.pub")
}

#resource "aws_security_group" "allow_ssh" {
#  name        = "allow_ssh"
#  description = "Allow SSH inbound traffic"

#  ingress {
#    description = "SSH from VPC"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

# define launch configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name            = "custom-launch-config"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  key_name        = resource.aws_key_pair.deployer-key.key_name
  security_groups = [aws_security_group.custom-instance-security-group.id]
  user_data       = file("scripts/startup_todoapp_service.sh")
}

# ELB dns output
output "elb" {
  description = "ELB DNS"
  value       = aws_elb.custom-elb.dns_name
}
