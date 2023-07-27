provider "aws" {
  region = "eu-west-1"
}

#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

#############
# RDS Aurora
#############
module "aurora-serverless" {
  source = "../../"

  name_prefix = "example-aurora-serverless"

  engine      = "aurora"
  engine_mode = "serverless"

  replica_count = 0

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.all.ids

  instance_type       = "db.t4g.medium"
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
