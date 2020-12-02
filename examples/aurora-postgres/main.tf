provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#####
# VPC and subnets
#####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.64"

  name = "simple-vpc-aurora-postgres"

  cidr = "10.0.0.0/16"

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = "test"
  }
}

module "aurora-postgresql" {
  source = "../.."

  name_prefix = "example-aurora-postgresql"

  engine                  = "aurora-postgresql"
  engine_version          = "11.7"
  engine_parameter_family = "aurora-postgresql11"

  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  iam_database_authentication_enabled = true

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  instance_type = "db.t3.medium"

  allowed_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24", "10.30.0.0/24"]

  tags = {
    Environment = "test"
    Engine      = "aurora-postgresql"
  }
}
