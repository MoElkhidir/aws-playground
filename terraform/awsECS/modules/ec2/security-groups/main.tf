variable "cluster_name" {}
variable "vpc_id" {}
variable "environment" {}


resource "aws_security_group" "lb_sg" {
    description = "controls access to the application ALB"

    vpc_id = var.vpc_id
    name   = "${var.environment}_load_balancer_security_group"

    ingress {
      protocol    = "tcp"
      from_port   = 80 # start of port range
      to_port     = 80 # end of port range
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port   = 0
      protocol  = "-1"

      cidr_blocks = [
        "0.0.0.0/0",
      ]
    }
  }

resource "aws_security_group" "ecs-security-group" {
  vpc_id      = var.vpc_id
  name        = "ecs"
  description = "security group for ECS"

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "incoming-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs-security-group.id
}

resource "aws_security_group_rule" "incoming-traffic-through-load-balancer" {
  type              = "ingress"
  from_port         = 32768
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs-security-group.id
  source_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "outgoing-traffic" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs-security-group.id
}

# Outputs
output "ecs_security_group_id" {
  value       = aws_security_group.ecs-security-group.id
}

output "application_load_balancer_security_group_id" {
  value       = aws_security_group.lb_sg.id
}