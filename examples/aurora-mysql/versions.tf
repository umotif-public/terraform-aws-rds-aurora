provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}
