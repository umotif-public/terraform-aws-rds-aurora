// aws_rds_cluster
output "rds_cluster_arn" {
  description = "The ID of the aurora cluster"
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_id" {
  description = "The ID of the cluster"
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_resource_id" {
  description = "The Resource ID of the cluster"
  value       = aws_rds_cluster.main.cluster_resource_id
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "rds_cluster_master_password" {
  description = "The master password"
  value       = aws_rds_cluster.main.master_password
  sensitive   = true
}

output "rds_cluster_port" {
  description = "The port"
  value       = aws_rds_cluster.main.port
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = aws_rds_cluster.main.master_username
}

output "rds_cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = aws_rds_cluster_instance.main.*.endpoint
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = join("", aws_security_group.main.*.id)
}

