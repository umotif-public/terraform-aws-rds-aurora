provider "aws" {
  region = "eu-west-1"
}

#####
# VPC and subnets
#####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.64"

  name = "simple-vpc-aurora-serverless"

  cidr = "10.0.0.0/16"

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = "test"
  }
}

module "aurora-serverless" {
  source = "../../"

  name_prefix = "example-aurora-serverless"

  engine                  = "aurora"
  engine_mode             = "serverless"
  engine_parameter_family = "aurora5.6"

  replica_count = 0

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  instance_type       = "db.t3.medium"
  apply_immediately   = true
  skip_final_snapshot = true
  storage_encrypted   = true

  iam_database_authentication_enabled = false # can't be set to true yet

  scaling_configuration = {
    auto_pause               = true
    max_capacity             = 256
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
