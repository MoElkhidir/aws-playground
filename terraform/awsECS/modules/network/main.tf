# variables

variable "vpc_cidr" {}
variable "environment" {}
variable "availability_zone" {
  type = list
}
variable "subnet_cidr" {}

# resources
module "vpc" {
    source = "./vpc"

    cidr = var.vpc_cidr
    environment = var.environment
}

module "subnet1" {
  source  = "./subnet"
  vpc_id = module.vpc.vpc_id
  subnet_cidr = var.subnet_cidr[0]
  availability_zone = var.availability_zone[0]
  name    = "public_subnet1"
  environment = var.environment
  assign_public_ip = true
  internet_gateway_id = module.vpc.internet_gateway_id
}

module "subnet2" {
  source  = "./subnet"
  vpc_id = module.vpc.vpc_id
  subnet_cidr = var.subnet_cidr[1]
  availability_zone = var.availability_zone[1]
  name    = "public_subnet2"
  environment = var.environment
  assign_public_ip = true
  internet_gateway_id = module.vpc.internet_gateway_id
}

# we might need internt gate way here

# outputs
output "vpc_id" {
  value       = module.vpc.vpc_id 
}

output "subnet1_id" {
  value       = module.subnet1.subnet_id
}

output "subnet2_id" {
  value       = module.subnet2.subnet_id
}