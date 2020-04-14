# variables
variable "registery_name" {}

# resources
resource "aws_ecr_repository" "app_registery" {
  name = var.registery_name
}


# outputs
output "ecr_url" {
  value       =  aws_ecr_repository.app_registery.repository_url
}