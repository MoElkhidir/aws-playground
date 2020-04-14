# Variables
variable "cidr" {
  description = "VPC cidr block. Example: 10.0.0.0/16"
}

variable "environment" {
  description = "The name of the environment"
}


# Resources
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = {
    Name  = var.environment
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.environment
    Environment = var.environment
  }
}

# Outputs
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "the generated VPC id"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main_igw.id
}