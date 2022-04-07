terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws    = ">= 3.15"
    random = ">= 2.3"
  }
}

provider "aws" {
  alias   = "blu_shared"
  region = "us-east-1"
  assume_role {
    role_arn     = var.assume_role
  }
}

