# variables
variable "ecr_url" {}
variable "app_family" {}
variable "app_name" {}
variable "cluster_id" {}
variable "ecs_service_role_arn" {}
variable "ecs_service_attachment_name" {}


# data
data "template_file" "app-task-definition-template" {
  template = file("${path.module}/templates/app.template.json")
  vars = {
    REPOSITORY_URL = replace(var.ecr_url, "https://", "")
    APP_NAME = var.app_name
  }
}


# resources
resource "aws_ecs_task_definition" "app-task-definition" {
  family                = var.app_family
  container_definitions = data.template_file.app-task-definition-template.rendered
}

resource "aws_ecs_service" "myapp-service" {
  name            = var.app_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app-task-definition.arn
  desired_count   = 1
  depends_on      = [var.ecs_service_attachment_name]

  lifecycle {
    ignore_changes = [task_definition]
  }
}