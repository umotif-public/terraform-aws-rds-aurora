#####
# Security Group resources
#####
resource "aws_security_group" "main" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name_prefix}-sg-"
  vpc_id      = var.vpc_id

  description = var.security_group_description == "" ? "Control traffic to/from RDS Aurora ${var.name_prefix}" : var.security_group_description

  tags = merge(var.tags,
    {
      Name = "${var.name_prefix}-sg"
    }
  )

  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "main_egress" {
  count = var.create_security_group ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.main.*.id)
}

resource "aws_security_group_rule" "main_default_ingress" {
  count = var.create_security_group ? length(var.allowed_security_groups) : 0

  description = "Ingress allowed from SGs"

  type                     = "ingress"
  from_port                = var.enable_global_cluster ? aws_rds_cluster.global[0].port : aws_rds_cluster.main[0].port
  to_port                  = var.enable_global_cluster ? aws_rds_cluster.global[0].port : aws_rds_cluster.main[0].port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.main.*.id)
}

resource "aws_security_group_rule" "main_cidr_ingress" {
  count = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description = "Ingress allowed from CIDRs"

  type              = "ingress"
  from_port         = var.enable_global_cluster ? aws_rds_cluster.global[0].port : aws_rds_cluster.main[0].port
  to_port           = var.enable_global_cluster ? aws_rds_cluster.global[0].port : aws_rds_cluster.main[0].port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.main.*.id)
}

#####
# RDS Aurora Resources
#####

resource "random_password" "master_password" {
  length  = 12
  special = false
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = var.name_prefix
  }

  byte_length = 4
}

resource "aws_db_subnet_group" "main" {
  count = var.db_subnet_group_name == "" ? 1 : 0

  name_prefix = "${var.name_prefix}-"
  description = "DB Subnet Group For Aurora cluster ${var.name_prefix}"
  subnet_ids  = var.subnets

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix
    }
  )
}

#####
# Standard RDS cluster
#####

resource "aws_rds_cluster" "main" {
  count = var.enable_global_cluster ? 0 : 1

  global_cluster_identifier     = var.global_cluster_identifier
  cluster_identifier            = var.name_prefix
  replication_source_identifier = var.replication_source_identifier

  source_region        = var.source_region
  engine               = var.engine
  engine_mode          = var.engine_mode
  engine_version       = var.engine_mode == "serverless" ? null : var.engine_version
  enable_http_endpoint = var.enable_http_endpoint

  kms_key_id = var.kms_key_id

  database_name   = var.database_name
  master_username = var.username
  master_password = var.password == "" ? random_password.master_password.result : var.password

  final_snapshot_identifier = "${var.final_snapshot_identifier_prefix}-${var.name_prefix}-${random_id.snapshot_identifier.hex}"
  skip_final_snapshot       = var.skip_final_snapshot
  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  deletion_protection          = var.deletion_protection
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_cluster_maintenance_window

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  port                   = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  db_subnet_group_name   = var.db_subnet_group_name == "" ? join("", aws_db_subnet_group.main.*.name) : var.db_subnet_group_name
  vpc_security_group_ids = compact(concat(aws_security_group.main.*.id, var.vpc_security_group_ids))
  storage_encrypted      = var.storage_encrypted

  db_cluster_parameter_group_name     = var.create_parameter_group ? aws_rds_cluster_parameter_group.main[0].id : var.db_cluster_parameter_group_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  backtrack_window = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0
  iam_roles        = var.iam_roles

  enabled_cloudwatch_logs_exports = [for log in var.enabled_cloudwatch_logs_exports : log.name]

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = lookup(restore_to_point_in_time.value, "source_cluster_identifier", null)
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  tags = merge(
    var.tags,
    var.cluster_tags
  )

  lifecycle {
    ignore_changes = [master_username, master_password, snapshot_identifier]
  }

  depends_on = [aws_cloudwatch_log_group.audit_log_group]
}

#####
# RDS cluster which is part of Global cluster
#####
resource "aws_rds_cluster" "global" {
  count = var.enable_global_cluster ? 1 : 0

  global_cluster_identifier     = var.global_cluster_identifier
  cluster_identifier            = var.name_prefix
  replication_source_identifier = var.replication_source_identifier

  source_region        = var.source_region
  engine               = var.engine
  engine_mode          = var.engine_mode
  engine_version       = var.engine_mode == "serverless" ? null : var.engine_version
  enable_http_endpoint = var.enable_http_endpoint

  kms_key_id = var.kms_key_id

  database_name   = var.database_name
  master_username = var.username
  master_password = var.password == "" ? random_password.master_password.result : var.password

  final_snapshot_identifier = "${var.final_snapshot_identifier_prefix}-${var.name_prefix}-${random_id.snapshot_identifier.hex}"
  skip_final_snapshot       = var.skip_final_snapshot
  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  deletion_protection          = var.deletion_protection
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_cluster_maintenance_window

  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately

  port                   = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  db_subnet_group_name   = var.db_subnet_group_name == "" ? join("", aws_db_subnet_group.main.*.name) : var.db_subnet_group_name
  vpc_security_group_ids = compact(concat(aws_security_group.main.*.id, var.vpc_security_group_ids))
  storage_encrypted      = var.storage_encrypted

  db_cluster_parameter_group_name     = var.create_parameter_group ? aws_rds_cluster_parameter_group.main[0].id : var.db_cluster_parameter_group_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  backtrack_window = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0
  iam_roles        = var.iam_roles

  enabled_cloudwatch_logs_exports = [for log in var.enabled_cloudwatch_logs_exports : log.name]

  dynamic "restore_to_point_in_time" {
    for_each = length(keys(var.restore_to_point_in_time)) == 0 ? [] : [var.restore_to_point_in_time]

    content {
      source_cluster_identifier  = lookup(restore_to_point_in_time.value, "source_cluster_identifier", null)
      restore_type               = lookup(restore_to_point_in_time.value, "restore_type", null)
      use_latest_restorable_time = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
      restore_to_time            = lookup(restore_to_point_in_time.value, "restore_to_time", null)
    }
  }

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  tags = merge(
    var.tags,
    var.cluster_tags
  )

  lifecycle {
    ignore_changes = [master_username, master_password, replication_source_identifier, snapshot_identifier]
  }

  depends_on = [aws_cloudwatch_log_group.audit_log_group]
}

resource "aws_rds_cluster_instance" "main" {
  count = var.replica_scale_enabled ? var.replica_scale_min : var.replica_count

  identifier         = try(var.instances_parameters[count.index].instance_name, "${var.name_prefix}-${count.index + 1}")
  cluster_identifier = var.enable_global_cluster ? aws_rds_cluster.global[0].id : aws_rds_cluster.main[0].id

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = try(var.instances_parameters[count.index].instance_type, var.instance_type)
  promotion_tier = try(var.instances_parameters[count.index].instance_promotion_tier, count.index + 1)

  publicly_accessible = var.publicly_accessible

  db_subnet_group_name    = var.db_subnet_group_name == "" ? join("", aws_db_subnet_group.main.*.name) : var.db_subnet_group_name
  db_parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.main[0].id : var.db_parameter_group_name

  preferred_maintenance_window = var.preferred_instance_maintenance_window
  apply_immediately            = var.apply_immediately

  monitoring_role_arn             = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  ca_cert_identifier              = var.ca_cert_identifier

  tags = merge(
    var.tags,
    var.cluster_instance_tags
  )

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

#####
# Parameter Groups
#####
resource "aws_rds_cluster_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0

  name   = "${var.name_prefix}-aurora-rds-cluster-pg"
  family = var.engine_parameter_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-aurora-rds-cluster-parameters",
    }
  )
}

resource "aws_db_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0

  name   = "${var.name_prefix}-aurora-rds-pg"
  family = var.engine_parameter_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-aurora-rds-parameters",
    }
  )
}

#####
# Enhanced monitoring IAM
#####
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name_prefix = "${var.name_prefix}-rds-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "AllowAssumeRoleMonitoringRDS"
    }
  ]
}
EOF

  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = join("", aws_iam_role.rds_enhanced_monitoring.*.name)
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_log_group" "audit_log_group" {
  for_each = { for export in var.enabled_cloudwatch_logs_exports : export.name => export }

  name = "/aws/rds/cluster/${var.name_prefix}/${lookup(each.value, "name")}"

  retention_in_days = lookup(each.value, "retention_in_days", null)
  kms_key_id        = lookup(each.value, "kms_key_id", null)
  tags              = var.tags
}

#####
# RDS Read Replicas Scaling
#####
resource "aws_appautoscaling_target" "read_replica" {
  count = var.replica_scale_enabled ? 1 : 0

  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = var.enable_global_cluster ? "cluster:${aws_rds_cluster.global[0].cluster_identifier}" : "cluster:${aws_rds_cluster.main[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "read_replica" {
  count = var.replica_scale_enabled ? 1 : 0

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = var.enable_global_cluster ? "cluster:${aws_rds_cluster.global[0].cluster_identifier}" : "cluster:${aws_rds_cluster.main[0].cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.replica_scale_in_cooldown
    scale_out_cooldown = var.replica_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.replica_scale_cpu : var.replica_scale_connections
  }

  depends_on = [aws_appautoscaling_target.read_replica]
}
