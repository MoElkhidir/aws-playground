# variables
variable "cluster_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_pair_name" {}
variable "iam_instance_profile_id" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "min_tasks_size" {}
variable "max_tasks_size" {}


resource "aws_security_group" "ecs-security-group" {
  vpc_id      = var.vpc_id
  name        = "ecs"
  description = "security group for ECS"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_launch_configuration" "ecs-example-launch-config" {
  name_prefix          = "ecs-launch-config"
  image_id             = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_pair_name
  iam_instance_profile = var.iam_instance_profile_id
  security_groups      = [aws_security_group.ecs-security-group.id]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=${var.cluster_name}' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                 = var.cluster_name
  vpc_zone_identifier  = [var.subnet_id]
  launch_configuration = aws_launch_configuration.ecs-example-launch-config.name
  min_size             = var.min_tasks_size
  max_size             = var.max_tasks_size
  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = aws_autoscaling_group.ecs-example-autoscaling.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-example-autoscaling.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

# resources
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight = 1
    base = 1
  }
}



# outputs
output "cluster_id" {
  value       = aws_ecs_cluster.ecs_cluster.id
}