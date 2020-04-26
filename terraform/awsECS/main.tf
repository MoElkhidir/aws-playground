terraform {
  required_providers {
    aws = "~> 2.58.0"
  }
}

provider "aws" {
  region = var.aws_region
  version = "~> 2.58.0"
  access_key=var.aws_access_key
  secret_key=var.aws_secret_key
}


# variables
  # aws provider
  variable "aws_access_key" {}
  variable "aws_secret_key" {}
  variable "aws_region" {}
  variable "aws_availability_zone" {}
  
  # vpc
  variable "vpc_cidr" {}
  variable "environment" {}

  # subnet
  variable "public_subnet_cidr" {}

  # ECR
  variable "app_registery_name" {}
  variable "nginx_registery_name" {}

  # IAM
  variable "public_key_name" {}
  variable "public_key_path" {}

  # ECS
  variable "cluster_name" {}
  variable "ami_id" {}
  variable "instance_type" {}
  variable "min_tasks_size" {}
  variable "max_tasks_size" {}

  # App
  variable "app_name" {}


# resources
module "network" {
  source = "./modules/network"
  
  vpc_cidr = var.vpc_cidr
  environment = var.environment
  availability_zone = var.aws_availability_zone
  subnet_cidr=var.public_subnet_cidr
}

module "ecr" {
  source  = "./modules/ecr"

  registery_name = var.app_registery_name
}

module "ecr-nginx" {
  source  = "./modules/ecr"

  registery_name = var.nginx_registery_name
}

module "iam" {
  source  = "./modules/iam"

  public_key_name = var.public_key_name
  public_key_path = var.public_key_path

}

module "security_groups" {
  source  = "./modules/ec2/security-groups"

  cluster_name = var.cluster_name
  vpc_id = module.network.vpc_id
  environment = var.environment
}

module "ecs" {
  source  = "./modules/ecs"

  cluster_name = var.cluster_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  key_pair_name = module.iam.key_pair_name
  iam_instance_profile_id = module.iam.ecs_ec2_role_id
  vpc_id = module.network.vpc_id
  subnet_id = module.network.subnet1_id
  min_tasks_size = var.min_tasks_size
  max_tasks_size = var.max_tasks_size
  ecs_security_group_id = module.security_groups.ecs_security_group_id

  virtual_dependency = [module.security_groups.ecs_security_group_id]
}

module "app" {
  source  = "./modules/app"
  ecr_url = module.ecr.ecr_url
  nginx_ecr_url = module.ecr-nginx.ecr_url
  app_family = var.environment
  app_name = var.app_name
  cluster_id = module.ecs.cluster_id
  ecs_service_role_arn = module.iam.ecs_service_role_arn
  ecs_service_attachment_name = module.iam.ecs_service_attachment_name
  vpc_id = module.network.vpc_id
  subnet_ids = [module.network.subnet1_id, module.network.subnet2_id]
  environment = var.environment
  application_load_balancer_security_group_id = module.security_groups.application_load_balancer_security_group_id

  virtual_dependency = [module.security_groups.application_load_balancer_security_group_id]

}