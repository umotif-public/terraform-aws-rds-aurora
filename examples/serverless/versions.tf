provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = "1.0.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.61"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.1"
    }
  }
}

