data "aws_iam_policy_document" "rds" {
  statement {
    sid = "Enable IAM User Permissions"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        data.aws_caller_identity.current.arn
      ]
    }
  }

  statement {
    sid = "Allow use of the key"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "rds.amazonaws.com",
        "monitoring.rds.amazonaws.com"
      ]
    }
  }
}

module "kms-ireland" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0"

  providers = {
    aws = aws.primary
  }

  alias_name              = "global-rds-kms-test-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.rds.json


  tags = {
    Environment = "test"
  }
}

module "kms-london" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0"

  providers = {
    aws = aws.secondary
  }

  alias_name              = "global-rds-kms-test-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.rds.json

  tags = {
    Environment = "test"
  }
}
