# variables

variable "vpc_cidr" {}
variable "environment" {}
variable "availability_zone" {}
variable "subnet_cidr" {}

# resources
module "vpc" {
    source = "./vpc"

    cidr = var.vpc_cidr
    environment = var.environment
}

module "subnet" {
  source  = "./subnet"
  vpc_id = module.vpc.vpc_id
  subnet_cidr = var.subnet_cidr
  availability_zone = var.availability_zone
  name    = "public_subnet"
  environment = var.environment
  assign_public_ip = true
  internet_gateway_id = module.vpc.internet_gateway_id
}


# we might need internt gate way here

# outputs
output "vpc_id" {
  value       = module.vpc.vpc_id 
}

output "subnet_id" {
  value       = module.subnet.subnet_id
}