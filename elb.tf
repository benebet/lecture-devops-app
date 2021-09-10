# AWS ELB configuration
resource "aws_elb" "custom-elb" {
  name = "custom-elb"
  subnets = [aws_subnet.customvpc-public-1.id,aws_subnet.customvpc-public-2.id] # The subnets from vpc.tf
  security_groups = [aws_security_group.custom-elb-security-group.id]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2 # Number of checks before instance is declared healthy
    unhealthy_threshold = 2 # Number of checks before instance is declared unhealthy
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  tags = {
    Name = "custom-elb"
  }
}

# Security group for elb
resource "aws_security_group" "custom-elb-security-group" {
  vpc_id = aws_vpc.custom-vpc.id
  name = "custom-elb-security-group"
  description = "The security group for the ELB"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "custom-elb-security-group"
  }
}

# Security group for the instances
resource "aws_security_group" "custom-instance-security-group" {
  vpc_id = aws_vpc.custom-vpc.id
  name = "custom-instance-security-group"
  description = "The security group for instances"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.custom-elb-security-group.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "custom-instance-security-group"
  }
}
