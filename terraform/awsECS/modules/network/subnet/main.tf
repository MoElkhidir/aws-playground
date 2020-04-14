# Modules that allows creating a subnet inside a VPC. This module can be used to create either a private or public-facing subnet

# variables
variable "vpc_id" {}
variable "subnet_cidr" {}
variable "availability_zone" {}
variable "name" {}
variable "environment" {}
variable "assign_public_ip" {
  type        = bool
  default     = false
}
variable "internet_gateway_id" {}

# resources
resource "aws_subnet" "subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = var.assign_public_ip

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_route_table" "routing_table" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routing_table.id
}


# outputs
output "subnet_id" {
  value       = aws_subnet.subnet.id
}
