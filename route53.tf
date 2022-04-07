locals {
  route53_record = "rds-${var.environment}-${var.name_prefix}"
  route53_read_record = "rds-ro-${var.environment}-${var.name_prefix}"
}

module "private_records" {
    count = var.private_record ? 1 : 0

    providers = {
	  aws = aws.blu_shared
    }

    private_zone  = true
    zone_name     = var.private_record_domain

    source = "git::git@github.com:Pagnet/tf-modules.git//aws-route53/modules/records"
    records = [
    {
      name      = local.route53_record
      type      = "CNAME"
      ttl       = "300"
      records   = [ var.enable_global_cluster ? join("", aws_rds_cluster.global.*.endpoint) : join("", aws_rds_cluster.main.*.endpoint) ]
    },

    {
      name      = local.route53_read_record
      type      = "CNAME"
      ttl       = "300"
      records   = [ var.enable_global_cluster ? join("", aws_rds_cluster.global.*.reader_endpoint) : join("", aws_rds_cluster.main.*.reader_endpoint) ]
    }
  ]
}


