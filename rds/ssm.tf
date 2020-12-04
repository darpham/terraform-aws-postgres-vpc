resource "aws_ssm_parameter" "db_hostname" {
  name        = "/${var.stage}/${var.region}/db_hostname"
  description = "database hostname"
  type        = "SecureString"
  value       = module.db.this_db_instance_endpoint
  overwrite   = true

  tags = var.tags
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.stage}/${var.region}/db_password"
  description = "database password"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true

  tags = var.tags
}