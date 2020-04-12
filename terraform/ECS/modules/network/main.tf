# variables

variable "vpc_cidr" {}
variable "environment" {}
variable "availability_zone" {}
variable "subnet_cidr" {}

# resources
module "vpc" {
    source = "./vpc"

    cidr = "${var.vpc_cidr}"
    environment = "${var.environment}"
}

module "subnet" {
  source  = "./subnet"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_cidr = "${var.subnet_cidr}"
  name    = "public_subnet"
}