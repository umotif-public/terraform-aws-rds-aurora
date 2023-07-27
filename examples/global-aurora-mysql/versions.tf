provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "primary"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-2"
}

terraform {
  required_version = ">= 1.0.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.55"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.1"
    }
  }
}

