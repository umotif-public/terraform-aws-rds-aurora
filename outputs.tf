#####
# aws_rds_cluster
#####
output "rds_cluster_arn" {
  description = "The ID of the aurora cluster"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.arn) : join("", aws_rds_cluster.main.*.arn)
}

output "rds_cluster_id" {
  description = "The ID of the cluster"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.id) : join("", aws_rds_cluster.main.*.id)
}

output "rds_cluster_resource_id" {
  description = "The Resource ID of the cluster"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.cluster_resource_id) : join("", aws_rds_cluster.main.*.cluster_resource_id)
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.endpoint) : join("", aws_rds_cluster.main.*.endpoint)
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.reader_endpoint) : join("", aws_rds_cluster.main.*.reader_endpoint)
}

output "rds_cluster_master_password" {
  description = "The master password"
  value       = var.enable_global_cluster ? aws_rds_cluster.global.*.master_password : aws_rds_cluster.main.*.master_password
  sensitive   = true
}

output "rds_cluster_port" {
  description = "The port"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.port) : join("", aws_rds_cluster.main.*.port)
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = var.enable_global_cluster ? join("", aws_rds_cluster.global.*.master_username) : join("", aws_rds_cluster.main.*.master_username)
}

#####
# aws_rds_cluster_instance
#####
output "rds_cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = aws_rds_cluster_instance.main.*.endpoint
}

output "rds_cluster_instance_ids" {
  description = "A list of all cluster instance ids"
  value       = aws_rds_cluster_instance.main.*.id
}

output "rds_cluster_instance_dbi_resource_ids" {
  description = "A list of all the region-unique, immutable identifiers for the DB instances"
  value       = aws_rds_cluster_instance.main.*.dbi_resource_id
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = join("", aws_security_group.main.*.id)
}

