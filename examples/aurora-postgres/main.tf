#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#############
# RDS Aurora
#############
module "aurora-postgresql" {
  source = "../.."

  name_prefix = "example-aurora-postgresql"

  engine                  = "aurora-postgresql"
  engine_version          = "15.3"
  engine_parameter_family = "aurora-postgresql15"

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
  subnets = data.aws_subnets.all.ids

  replica_count = 1
  instance_type = "db.t4g.medium"

  allowed_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24", "10.30.0.0/24"]

  tags = {
    Environment = "test"
    Engine      = "aurora-postgresql"
  }
}
