provider "aws" {
  region = "${var.aws_region}"
  version = "~> 2.57"
  access_key="${var.aws_access_key}"
  secret_key="${var.aws_secret_key}"
}


# variables
variable "vpc_cidr" {}
variable "environment" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

# resources
module "network" {
  source = "modules/network"
  
  vpc_cidr = "${var.vpc_cidr}"
  environment = "${var.environment}"
  availability_zone = "${var.aws_region}a"
}
