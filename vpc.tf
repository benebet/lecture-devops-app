# Create a AWS VPC
resource "aws_vpc" "custom-vpc" {
  cidr_block           = "172.25.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  tags = {
    Name = "custom-vpc"
  }
}

# Public subnets for the VPC
resource "aws_subnet" "customvpc-public-1" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = "172.25.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "custom-vpc-public-1"
  }
}
resource "aws_subnet" "customvpc-public-2" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = "172.25.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "custom-vpc-public-2"
  }
}

# Private subnet for the VPC
resource "aws_subnet" "customvpc-private" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = "172.25.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name = "custom-vpc-private"
  }
}

# Internet gateway for public subnets
resource "aws_internet_gateway" "customvpc-gateway" {
  vpc_id = aws_vpc.custom-vpc.id
  tags = {
    Name = "custom-vpc-internet-gateway"
  }
}

# Routing table
resource "aws_route_table" "customvpc-route-table" {
  vpc_id = aws_vpc.custom-vpc.id
  route {
    cidr_block = "0.0.0.0/0" # All IPs
    gateway_id = aws_internet_gateway.customvpc-gateway.id
  }
  tags = {
    Name = "custom-vpc-route-table"
  }
}

# Routing table association
resource "aws_route_table_association" "customvpc-route-association-public-1" {
  subnet_id      = aws_subnet.customvpc-public-1.id
  route_table_id = aws_route_table.customvpc-route-table.id
}
resource "aws_route_table_association" "customvpc-route-association-public-2" {
  subnet_id      = aws_subnet.customvpc-public-2.id
  route_table_id = aws_route_table.customvpc-route-table.id
}
