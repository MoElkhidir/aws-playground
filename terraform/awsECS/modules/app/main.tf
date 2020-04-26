# variables
variable "ecr_url" {}
variable "nginx_ecr_url" {}
variable "app_family" {}
variable "app_name" {}
variable "cluster_id" {}
variable "ecs_service_role_arn" {}
variable "ecs_service_attachment_name" {}
variable "vpc_id" {}
variable "environment" {}
variable "subnet_ids" {
  type        = list
}
variable "application_load_balancer_security_group_id" {}
variable "virtual_dependency" {
  type    = any
  default = null
}

# data
data "template_file" "app-task-definition-template" {
  template = file("${path.module}/templates/app.template.json")
  vars = {
    REPOSITORY_URL = replace(var.ecr_url, "https://", "")
    NGINX_REPOSITORY_URL = replace(var.nginx_ecr_url, "https://", "")
    APP_NAME = var.app_name
  }
}


# resources
resource "aws_ecs_task_definition" "app-task-definition" {
  family                = var.app_family
  container_definitions = data.template_file.app-task-definition-template.rendered
  network_mode = "bridge"
}
  
  
  #Application Load Balancer
  resource "aws_lb_target_group" "load-balancer-target-group" {
    name     = var.environment
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id
  }

  resource "aws_lb" "main-load-balancer" {
    name            = var.environment
    load_balancer_type = "application"
    subnets         = var.subnet_ids
    security_groups = [var.application_load_balancer_security_group_id]
    tags = {
      Environment = var.environment
    }

    depends_on = [var.virtual_dependency]
  }

  resource "aws_lb_listener" "load-balancer-listner" {
    load_balancer_arn = aws_lb.main-load-balancer.id
    port              = "80"
    protocol          = "HTTP"

    default_action {
      target_group_arn = "${aws_lb_target_group.load-balancer-target-group.id}"
      type             = "forward"
    }
  }

resource "aws_lb_listener_rule" "static" {
  listener_arn = "${aws_lb_listener.load-balancer-listner.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.load-balancer-target-group.arn}"
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_ecs_service" "myapp-service" {
  name            = var.app_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app-task-definition.arn
  desired_count   = 1
  depends_on      = [var.ecs_service_attachment_name]
  iam_role        = var.ecs_service_role_arn

  # we specify the target group which the instance will be part of so the load balancer forward the requests to.
  # we specify the container and it's port because we use dynamic mapping, so when a container is started for the first time
  # the load balancer knows how to map the ec2 port to the container port 
  load_balancer {
    target_group_arn = aws_lb_target_group.load-balancer-target-group.arn
    container_name = var.app_name
    container_port = 3000
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}