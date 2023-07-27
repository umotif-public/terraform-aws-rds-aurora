#####
# aws_rds_cluster
#####
output "rds_cluster_arn" {
  description = "The ID of the aurora cluster"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].arn : aws_rds_cluster.main[0].arn
}

output "rds_cluster_id" {
  description = "The ID of the cluster"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].id : aws_rds_cluster.main[0].id
}

output "rds_cluster_resource_id" {
  description = "The Resource ID of the cluster"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].cluster_resource_id : aws_rds_cluster.main[0].cluster_resource_id
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].endpoint : aws_rds_cluster.main[0].endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].reader_endpoint : aws_rds_cluster.main[0].reader_endpoint
}

output "rds_cluster_master_password" {
  description = "The master password"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].master_password : aws_rds_cluster.main[0].master_password
  sensitive   = true
}

output "rds_cluster_port" {
  description = "The port"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].port : aws_rds_cluster.main[0].port
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = var.enable_global_cluster ? aws_rds_cluster.global[0].master_username : aws_rds_cluster.main[0].master_username
}

#####
# aws_rds_cluster_instance
#####
output "rds_cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = aws_rds_cluster_instance.main[*].endpoint
}

output "rds_cluster_instance_arns" {
  description = "A list of all cluster instance ARNs"
  value       = aws_rds_cluster_instance.main[*].arn
}

output "rds_cluster_instance_ids" {
  description = "A list of all cluster instance ids"
  value       = aws_rds_cluster_instance.main[*].id
}

output "rds_cluster_instance_dbi_resource_ids" {
  description = "A list of all the region-unique, immutable identifiers for the DB instances"
  value       = aws_rds_cluster_instance.main[*].dbi_resource_id
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = aws_security_group.main[0].id
}

