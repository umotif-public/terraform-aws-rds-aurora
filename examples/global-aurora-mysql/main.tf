provider "aws" {
  region  = "eu-west-1"
  version = ">= 3.14"
}

provider "aws" {
  alias   = "primary"
  region  = "eu-west-1"
  version = ">= 3.14"
}

provider "aws" {
  alias   = "secondary"
  region  = "eu-west-2"
  version = ">= 3.14"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#####
# VPC and subnets
#####
module "vpc_ireland" {
  providers = {
    aws = aws.primary
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.63"

  name = "simple-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

module "vpc_london" {
  providers = {
    aws = aws.secondary
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.63"

  name = "simple-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

resource "aws_rds_global_cluster" "main" {
  provider = aws.primary

  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.08.0"
  global_cluster_identifier = "main-global-mysql-cluster"
  deletion_protection       = false

  storage_encrypted = true

  lifecycle {
    ignore_changes = [engine_version]
  }
}

#############
# RDS Aurora
#############
module "aurora_primary" {
  source = "../../"

  providers = {
    aws = aws.primary
  }

  global_cluster_identifier = aws_rds_global_cluster.main.id

  name_prefix         = "example-aurora-mysql-ireland"
  engine_mode         = "provisioned"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.08.1"
  deletion_protection = false

  storage_encrypted = true
  kms_key_id        = module.kms-ireland.key_arn

  vpc_id  = module.vpc_ireland.vpc_id
  subnets = module.vpc_ireland.public_subnets

  replica_count               = 1
  instance_type               = "db.r5.large"
  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  create_security_group = true

  tags = {
    Environment = "test"
  }

  depends_on = [aws_rds_global_cluster.main]
}

module "aurora_secondary" {
  source = "../../"

  providers = {
    aws = aws.secondary
  }

  source_region             = "eu-west-1"
  global_cluster_identifier = aws_rds_global_cluster.main.id

  name_prefix         = "example-aurora-mysql-london"
  engine_mode         = "provisioned"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.08.1"
  deletion_protection = false

  storage_encrypted = true
  kms_key_id        = module.kms-london.key_arn

  username = null
  password = null

  vpc_id  = module.vpc_london.vpc_id
  subnets = module.vpc_london.public_subnets

  replica_count               = 1
  instance_type               = "db.r5.large"
  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  create_security_group = true

  tags = {
    Environment = "test"
  }

  depends_on = [module.aurora_primary, aws_rds_global_cluster.main]
}

