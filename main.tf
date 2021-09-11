terraform {
  # Require aws as provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.15.1"
}

# AMI_ID as input variable for terraform
variable "ami_id" {
  type = string
}

# TODO needed?
variable "data_volumes" {
  type = list(object({
    ebs_volume_id = string
    availability_zone = string
  }))
  description = "List of EBS volumes"
  default = []
}

# Set region to use (us-east-1 needed for educate account)
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Key pair for SSH
resource "aws_key_pair" "deployer-key" {
  key_name   = "deployer-key"
  public_key = file(".ssh/id_rsa.pub")
}

# define launch configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name            = "custom-launch-config"
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  key_name        = resource.aws_key_pair.deployer-key.key_name
  security_groups = [aws_security_group.custom-instance-security-group.id]
  #FIXME - AWS does not seem to launch script properly - maybe wrong enter directory?
  user_data       = file("scripts/startup_todoapp_service.sh")
}

# ELB dns output
output "elb" {
  description = "ELB DNS"
  value       = aws_elb.custom-elb.dns_name
}
