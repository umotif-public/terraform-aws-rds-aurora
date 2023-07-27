data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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
module "aurora" {
  source = "../../"

  name_prefix         = "example-aurora-mysql"
  database_name       = "databaseName"
  engine              = "aurora-mysql"
  deletion_protection = false

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnets.all.ids

  kms_key_id = module.kms.key_arn

  replica_count               = 1
  instance_type               = "db.t4g.medium"
  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = [
    {
      name              = "audit",
      retention_in_days = "60"
      kms_key_id        = module.kms-cloudwatch.key_arn
    },
    {
      name       = "error"
      kms_key_id = module.kms-cloudwatch.key_arn
    },
    {
      name              = "general",
      retention_in_days = "30"
    },
    {
      name = "slowquery",
    }
  ]

  allowed_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24", "10.30.0.0/24"]

  monitoring_interval = 60

  create_security_group = true

  cluster_tags = {
    "cluster_tags" = "example cluster main"
  }

  cluster_instance_tags = {
    "cluster_instance_tags" = "example of cluster instance tags"
  }

  tags = {
    Environment = "test"
  }
}

