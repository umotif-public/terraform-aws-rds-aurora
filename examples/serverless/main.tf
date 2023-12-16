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
module "aurora-serverless-v2" {
  source = "../../"

  name_prefix = "example-aurora-serverless-v2"

  engine         = "aurora-mysql"
  engine_mode    = "provisioned"
  engine_version = "8.0.mysql_aurora.3.05.1"

  replica_scale_enabled = true
  replica_scale_min     = 1
  replica_scale_max     = 2

  manage_master_user_password = false

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnets.all.ids

  instance_type       = "db.serverless"
  apply_immediately   = true
  skip_final_snapshot = true
  storage_encrypted   = true

  iam_database_authentication_enabled = true

  serverlessv2_scaling_configuration = {
    max_capacity = 1
    min_capacity = 0.5
  }
}
