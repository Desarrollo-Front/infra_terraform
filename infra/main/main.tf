terraform {
  backend "s3" {
    bucket         = "manu-tfstate-172886169632"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "manu-tf-locks"
  }

  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

