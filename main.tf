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

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "todoapp" {
  key_name        = resource.aws_key_pair.deployer-key.key_name
  security_groups = [resource.aws_security_group.allow_ssh.name]
  ami             = var.ami_id
  instance_type   = "t2.micro"

  tags = {
    Name = "TODO_APP_INSTANCE"
  }
}

resource "aws_key_pair" "deployer-key" {
  key_name = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# define autoscaling launch configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name = "custom-launch-config"
  image_id = var.ami_id
  instance_type = "t2.micro"
  key_name = resource.aws_key_pair.deployer-key.key_name
}

# define autoscaling group
resource "aws_autoscaling_group" "custom-autoscaling-group" {
  name = "custom-autoscaling-group"
  vpc_zone_identifier = ["subnet-d1682ef0"]
  launch_configuration = aws_launch_configuration.custom-launch-config.name
  min_size = 1
  max_size = 3
  health_check_grace_period = 100
  health_check_type = "EC2"
  force_delete = true
  tag {
    key = "Name"
    value = "todoapp_instace"
    propagate_at_launch = true
  }
}

# define autoscaling configuration policy
resource "aws_autoscaling_policy" "custom-cpu-policy" {
  name = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.custom-autoscaling-group.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
  cooldown = 30
  policy_type = "SimpleScaling"
}

# define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
  alarm_name = "custom-cpu-alarm"
  alarm_description = "Alarm on CPU usage increase"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 20
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.custom-autoscaling-group.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# define descaling policy
resource "aws_autoscaling_policy" "custom-cpu-policy-scaledown" {
  name = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.custom-autoscaling-group.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1
  cooldown = 60
  policy_type = "SimpleScaling"
}

# define cloud watch monitoring for descaling
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm-scaledown" {
  alarm_name = "custom-cpu-alarm-scaledown"
  alarm_description = "Alarm on CPU usage decrease"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 10
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.custom-autoscaling-group.name
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy-scaledown.arn]
}

# public ip output
output "instance_public_ip" {
  description = "Public IP Address of AWS instance"
  value       = aws_instance.todoapp.public_ip
}
