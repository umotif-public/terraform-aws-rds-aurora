# terraform-aws-rds-aurora
Terraform module which creates AWS RDS Aurora resources. This module was created to work with Secrets Manager.

## Terraform versions

Terraform 0.12. Pin module version to `~> v1.0`. Submit pull-requests to `master` branch.

## Usage

```hcl
module "rds-aurora-mysql" {
  source = "umotif-public/rds-aurora/aws"
  version = "~> 1.0.0"

  name_prefix         = "example-aurora-mysql"
  engine              = "aurora-mysql"
  engine_version      = "5.7.12"
  deletion_protection = true

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  replica_count                       = 2
  instance_type                       = "db.r5.large"
  apply_immediately                   = true
  skip_final_snapshot                 = true

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  iam_database_authentication_enabled = true

  allowed_cidr_blocks             = ["10.10.0.0/24", "20.10.0.0/24"]

  create_security_group = true

  monitoring_interval = 60
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

  tags = {
    Environment = "test"
  }
}
```

## Assumptions

Module is to be used with Terraform > 0.12.

## Examples

* [Aurora MySQL](https://github.com/umotif-public/terraform-aws-rds-aurora/tree/master/examples/aurora-mysql)

## Authors

Module managed by [Marcin Cuber](https://github.com/marcincuber) [LinkedIn](https://www.linkedin.com/in/marcincuber/).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.6 |
| aws | ~> 2.45 |
| random | ~> 2.2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.45 |
| random | ~> 2.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr\_blocks | A list of CIDR blocks which are allowed to access the database | `list(string)` | `[]` | no |
| allowed\_security\_groups | A list of Security Group ID's to allow access to. | `list(string)` | `[]` | no |
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | `bool` | `false` | no |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | `bool` | `true` | no |
| backtrack\_window | The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| backup\_retention\_period | How long to keep backups for (in days) | `number` | `7` | no |
| ca\_cert\_identifier | The identifier of the CA certificate for the DB instance. | `string` | `"rds-ca-2019"` | no |
| cluster\_instance\_tags | Additional tags for the cluster instance | `map(string)` | `{}` | no |
| cluster\_tags | Additional tags for the cluster | `map(string)` | `{}` | no |
| copy\_tags\_to\_snapshot | Copy all Cluster tags to snapshots. | `bool` | `false` | no |
| create\_monitoring\_role | Whether to create the IAM role for RDS enhanced monitoring | `bool` | `true` | no |
| create\_security\_group | Whether to create security group for RDS cluster | `bool` | `true` | no |
| database\_name | Name for an automatically created database on cluster creation | `string` | `""` | no |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | `string` | `null` | no |
| db\_parameter\_group\_name | The name of a DB parameter group to use | `string` | `null` | no |
| db\_subnet\_group\_name | The existing subnet group name to use | `string` | `""` | no |
| deletion\_protection | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| enable\_http\_endpoint | Whether or not to enable the Data API for a serverless Aurora database engine. | `bool` | `false` | no |
| enabled\_cloudwatch\_logs\_exports | List of object which define log types to export to cloudwatch. See in examples. | `list` | `[]` | no |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | `string` | `"aurora"` | no |
| engine\_mode | The database engine mode. Valid values: global, parallelquery, provisioned, serverless. | `string` | `"provisioned"` | no |
| engine\_version | Aurora database engine version. | `string` | `"5.7.12"` | no |
| final\_snapshot\_identifier\_prefix | The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | `string` | `"final"` | no |
| global\_cluster\_identifier | The global cluster identifier specified on aws\_rds\_global\_cluster | `string` | `""` | no |
| iam\_database\_authentication\_enabled | Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported. | `bool` | `true` | no |
| iam\_roles | A List of ARNs for the IAM roles to associate to the RDS Cluster. | `list(string)` | `[]` | no |
| instance\_type | Instance type to use | `string` | n/a | yes |
| instances\_parameters | Individual settings for instances. | `list` | `[]` | no |
| kms\_key\_id | The ARN for the KMS encryption key if one is set to the cluster. | `string` | `""` | no |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| monitoring\_role\_arn | IAM role for RDS to send enhanced monitoring metrics to CloudWatch | `string` | `""` | no |
| name\_prefix | Prefix Name used across all resources | `string` | n/a | yes |
| password | Master DB password | `string` | `""` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| performance\_insights\_kms\_key\_id | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `""` | no |
| permissions\_boundary | The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| port | The port on which to accept connections | `string` | `""` | no |
| predefined\_metric\_type | The metric type to scale on. Valid values are RDSReaderAverageCPUUtilization and RDSReaderAverageDatabaseConnections. | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| preferred\_backup\_window | When to perform DB backups | `string` | `"02:00-03:00"` | no |
| preferred\_cluster\_maintenance\_window | When to perform maintenance on the cluster | `string` | `"sun:05:00-sun:06:00"` | no |
| preferred\_instance\_maintenance\_window | When to perform maintenance on the instances | `string` | `"sun:05:00-sun:06:00"` | no |
| publicly\_accessible | Whether the DB should have a public IP address | `bool` | `false` | no |
| replica\_count | Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead. | `number` | `1` | no |
| replica\_scale\_connections | Average number of connections to trigger autoscaling at. Default value is 70% of db.r4.large's default max\_connections | `number` | `700` | no |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | `number` | `70` | no |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | `bool` | `false` | no |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | `number` | `300` | no |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | `number` | `0` | no |
| replica\_scale\_min | Minimum number of replicas to allow scaling for | `number` | `2` | no |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | `number` | `300` | no |
| replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. | `string` | `""` | no |
| scaling\_configuration | Map of nested attributes with scaling properties. Only valid when engine\_mode is set to `serverless` | `map(string)` | `{}` | no |
| security\_group\_description | The description of the security group. If value is set to empty string it will contain cluster name in the description. | `string` | `""` | no |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | `bool` | `false` | no |
| snapshot\_identifier | DB snapshot to create this database from | `string` | `""` | no |
| source\_region | The source region for an encrypted replica DB cluster. | `string` | `""` | no |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | `bool` | `true` | no |
| subnets | List of subnet IDs to use | `list(string)` | `[]` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| username | Master DB username | `string` | `"root"` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |
| vpc\_security\_group\_ids | List of VPC security groups to associate to the cluster in addition to the SG that can be created in this module. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| rds\_cluster\_arn | The ID of the aurora cluster |
| rds\_cluster\_endpoint | The cluster endpoint |
| rds\_cluster\_id | The ID of the cluster |
| rds\_cluster\_instance\_endpoints | A list of all cluster instance endpoints |
| rds\_cluster\_master\_password | The master password |
| rds\_cluster\_master\_username | The master username |
| rds\_cluster\_port | The port |
| rds\_cluster\_reader\_endpoint | The cluster reader endpoint |
| rds\_cluster\_resource\_id | The Resource ID of the cluster |
| security\_group\_id | The security group ID of the cluster |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

See LICENSE for full details.

## Pre-commit hooks

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

#### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```