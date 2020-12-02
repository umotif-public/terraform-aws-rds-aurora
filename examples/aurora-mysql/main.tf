provider "aws" {
  region = "eu-west-1"
}

#####
# VPC and subnets
#####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.64"

  name = "simple-rds-aurora-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

#############
# RDS Aurora
#############
module "aurora" {
  source = "../../"

  name_prefix         = "example-aurora-mysql"
  database_name       = "databaseName"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.09.0"
  deletion_protection = false

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  kms_key_id = module.kms.key_arn

  replica_count               = 1
  instance_type               = "db.t3.medium"
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

