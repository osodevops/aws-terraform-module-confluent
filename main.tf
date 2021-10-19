provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  for_each = var.project
  cidr     = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, each.value.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, each.value.public_subnet_count)

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"
  zones = {
    "confluent.internal" = {
      comment = "confluent.internal"
    }
  }
  tags = {
    ManagedBy = "Terraform"
  }
}

module "internal_comms_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.3.0"
  for_each = var.project

  name        = "internal-comms-sg-${each.key}-${each.value.environment}"
  description = "Security group to allow all confluent components to speak with each other."
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
  ingress_rules        = ["all-all"]
}

module "kafka_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/kafka"
  version = "4.3.0"
  for_each = var.project

  name        = "kafka-sg-${each.key}-${each.value.environment}"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
}

module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "4.3.0"
  for_each = var.project

  name        = "ssh-sg-${each.key}-${each.value.environment}"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

//  ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
}

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38.0"
    }
  }
  backend "s3" {
    bucket         = "aws-oso-confluent"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "eu-west-2"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform-lock"
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}