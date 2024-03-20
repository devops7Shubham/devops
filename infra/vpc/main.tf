
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
# data "aws_availability_zones" "available" {
#   state = "available"
# }
# locals {
#   azs="${data.aws_availability_zones.available.names}"
# }
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_az1_cidr 
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch=var.map_public_ip_on_launch
 
  tags = {
    Name = "Main"
  }
}
resource "aws_subnet" "second_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_az2_cidr 
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch=var.map_public_ip_on_launch


  tags = {
    Name = "Main2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "example"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "TLS from VPC"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_tls"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = var.ip_protocol # semantically equivalent to all ports
  
  
}
# resource "aws_security_group_rule" "example" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "tcp"
#   cidr_blocks       = []
#   security_group_id = aws_security_group.allow_tls.id
# }