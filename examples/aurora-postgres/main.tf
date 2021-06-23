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
module "aurora-postgresql" {
  source = "../.."

  name_prefix = "example-aurora-postgresql"

  engine                  = "aurora-postgresql"
  engine_version          = "11.8"
  engine_parameter_family = "aurora-postgresql11"

  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = [
    {
      name = "postgresql"
    }
  ]

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.all.ids

  replica_count = 1
  instance_type = "db.t3.medium"

  allowed_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24", "10.30.0.0/24"]

  tags = {
    Environment = "test"
    Engine      = "aurora-postgresql"
  }
}
