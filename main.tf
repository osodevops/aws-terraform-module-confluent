module "state" {
  source = ".//modules/state"
}

//terraform {
//  required_providers {
//    aws = {
//      source  = "hashicorp/aws"
//      version = "~> 3.0"
//    }
//  }
//  backend "s3" {
//    bucket         = "aws-oso-confluent"
//    key            = "terraform.tfstate"
//    encrypt        = true
//    region         = "eu-west-2"
//    acl            = "bucket-owner-full-control"
//    dynamodb_table = "terraform-lock"
//  }
//}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}


