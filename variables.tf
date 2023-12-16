variable "create_security_group" {
  description = "Whether to create security group for RDS cluster"
  type        = bool
  default     = true
}

variable "create_parameter_group" {
  type        = bool
  description = "Whether to create parameter groups for RDS cluster and RDS instances"
  default     = true
}

variable "name_prefix" {
  description = "Prefix Name used across all resources"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs to use"
  type        = list(string)
  default     = []
}

variable "replica_count" {
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
  default     = 1
  type        = number
}

variable "allowed_security_groups" {
  description = "A list of Security Group ID's to allow access to."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the DB should have a public IP address"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = ""
}

variable "master_username" {
  description = "Master DB username"
  type        = string
  default     = "root"
}

variable "master_password" {
  description = "Master DB password"
  type        = string
  default     = ""
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
  type        = string
  default     = "final"
}

variable "skip_final_snapshot" {
  description = "Should a final snapshot be created on cluster destroy"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00"
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = ""
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to false"
  type        = bool
  default     = null
}

variable "db_parameter_group_name" {
  description = "The name of a DB parameter group to use"
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_name" {
  description = "The name of a DB Cluster parameter group to use"
  type        = string
  default     = null
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when engine_mode is set to `serverless`"
  type        = map(string)
  default     = {}
}

variable "snapshot_identifier" {
  description = "DB snapshot to create this database from"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the underlying storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster."
  type        = string
  default     = null
}

variable "engine" {
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql"
  type        = string
  default     = "aurora"
}

variable "engine_version" {
  description = "Aurora database engine version."
  type        = string
  default     = "8.0.mysql_aurora.3.03.1"
}

variable "engine_parameter_family" {
  description = "The database engine paramater group family"
  default     = "aurora-mysql8.0"
  type        = string
}

variable "enable_http_endpoint" {
  description = "Whether or not to enable the Data API for a serverless Aurora database engine."
  type        = bool
  default     = false
}

variable "replica_scale_enabled" {
  description = "Whether to enable autoscaling for RDS Aurora (MySQL) read replicas"
  type        = bool
  default     = false
}

variable "replica_scale_max" {
  description = "Maximum number of replicas to allow scaling for"
  type        = number
  default     = 2
}

variable "replica_scale_min" {
  description = "Minimum number of replicas to allow scaling for"
  type        = number
  default     = 0
}

variable "replica_scale_cpu" {
  description = "CPU usage to trigger autoscaling at"
  type        = number
  default     = 70
}

variable "replica_scale_connections" {
  description = "Average number of connections to trigger autoscaling at. Default value is 70% of db.r4.large's default max_connections"
  type        = number
  default     = 700
}

variable "replica_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "replica_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of object which define log types to export to AWS Cloudwatch. See in examples."
  type        = list(any)
  default     = []
}

variable "global_cluster_identifier" {
  description = "The global cluster identifier specified on aws_rds_global_cluster"
  type        = string
  default     = ""
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: global, parallelquery, provisioned, serverless."
  type        = string
  default     = "provisioned"
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica."
  default     = null
  type        = string
}

variable "source_region" {
  description = "The source region for an encrypted replica DB cluster."
  default     = null
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG that can be created in this module."
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "The existing subnet group name to use"
  type        = string
  default     = ""
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are RDSReaderAverageCPUUtilization and RDSReaderAverageDatabaseConnections."
  default     = "RDSReaderAverageCPUUtilization"
  type        = string
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours)"
  type        = number
  default     = 0
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster tags to snapshots."
  type        = bool
  default     = false
}

variable "iam_roles" {
  description = "A Map of ARNs for the IAM roles to associate to the RDS Cluster."
  type        = map(map(string))
  default     = {}
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description."
  type        = string
  default     = ""
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  type        = string
  default     = "rds-ca-rsa4096-g1"
}

variable "instances_parameters" {
  description = "Individual settings for instances."
  default     = []
  type        = list(string)
}

variable "preferred_cluster_maintenance_window" {
  description = "When to perform maintenance on the cluster"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "preferred_instance_maintenance_window" {
  description = "When to perform maintenance on the instances"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

variable "monitoring_role_arn" {
  description = "IAM role for RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = null
}

variable "create_monitoring_role" {
  description = "Whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "cluster_tags" {
  description = "Additional tags for the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_instance_tags" {
  description = "Additional tags for the cluster instance"
  type        = map(string)
  default     = {}
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of parameter objects"
  default     = []
}

variable "cluster_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  description = "A list of cluster parameter objects"
  default     = []
}

variable "enable_global_cluster" {
  type        = bool
  description = "Set this variable to `true` if DB Cluster is going to be part of a Global Cluster."
  default     = false
}

variable "restore_to_point_in_time" {
  description = "Restore to point in time configuration. See docs for arguments https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#restore_to_point_in_time-argument-reference"
  type        = map(string)
  default     = {}
}

variable "s3_import" {
  description = "Restore from a Percona XtraBackup stored in S3 bucket. Only Aurora MySQL is supported."
  type        = map(string)
  default     = null
}

variable "serverlessv2_scaling_configuration" {
  description = "Nested attribute with scaling properties for ServerlessV2. Only valid when `engine_mode` is set to `provisioned`"
  type        = map(string)
  default     = {}
}

variable "allocated_storage" {
  description = "The amount of storage in gibibytes (GiB) to allocate to each DB instance in the Multi-AZ DB cluster"
  type        = number
  default     = null
}

variable "availability_zones" {
  description = "List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply."
  type        = list(string)
  default     = null
}

variable "iops" {
  description = "Amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster."
  type        = number
  default     = null
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key. To use a KMS key in a different Amazon Web Services account, specify the key ARN or alias ARN. If not specified, the default KMS key for your Amazon Web Services account is used."
  type        = string
  default     = null
}

variable "network_type" {
  description = "Network type of the cluster. Valid values: IPV4, DUAL."
  type        = string
  default     = null
}