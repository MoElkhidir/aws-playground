# Modules that allows creating a subnet inside a VPC. This module can be used to create either a private or public-facing subnet

# variables
variable "vpc_id" {}
variable "subnet_cidr" {}
variable "availability_zone" {}
variable "name" {}
variable "environment" {}


# resources
resource "aws_subnet" "subnet" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.subnet_cidr}"
  availability_zone = "${var.aws_ravailability_zoneegion}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# We are creating one more subnets that we want to address as one, therefore we create a routing table and 
# add all the subnets to it. This allows us to easier create routing to all the subnets at once.
# For example when creating a route to the Internet Gateway 
resource "aws_route_table" "subnet" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(var.cidrs)}"

  tags {
    Name        = "${var.name}_${element(var.availability_zones, count.index)}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "subnet" {
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.subnet.*.id, count.index)}"
  count          = "${length(var.cidrs)}"
}