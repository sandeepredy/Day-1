# Create VPC
# terraform aws create vpc
resource "aws_vpc" "sandeep_vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "sandeep_VPC"
  }
}
# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "sandeep-internet-gateway" {
  vpc_id = aws_vpc.sandeep_vpc.id
  tags = {
    Name = "sandeep_internet_gateway"
  }
}
# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "sandeep-public-subnet-1" {
  vpc_id                  = aws_vpc.sandeep_vpc.id
  cidr_block              = var.Public_Subnet_1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "sandeep public-subnet-1"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "sandeep-public-route-table" {
  vpc_id = aws_vpc.sandeep_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandeep-internet-gateway.id
  }
  tags = {
    Name = "sandeep Public Route Table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.sandeep-public-subnet-1.id
  route_table_id = aws_route_table.sandeep-public-route-table.id
}
# Create Private Subnet 1
# terraform aws create subnet
resource "aws_subnet" "sandeep-private-subnet-1" {
  vpc_id                  = aws_vpc.sandeep_vpc.id
  cidr_block              = var.Private_Subnet_1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "sandeep_private-subnet-1"
  }
}

# Create Security Group for the Bastion Host aka Jump Box
# terraform aws create security group
resource "aws_security_group" "sandeep-ssh-security-group" {
  name        = "SSH Security Group"
  description = "Enable SSH access on Port 22"
  vpc_id      = aws_vpc.sandeep_vpc.id
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sandeep SSH Security Group"
  }
}

resource "aws_security_group" "sandeep-webserver-security-group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP/HTTPS access on Port 80/443 via ALB and SSH access on Port 22 via SSH SG"
  vpc_id      = aws_vpc.sandeep_vpc.id
  ingress {
    description     = "SSH Access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sandeep-ssh-security-group.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Web Server Security Group"
  }
}