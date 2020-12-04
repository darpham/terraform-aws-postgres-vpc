provider "aws" {
  version = "2.64.0"
  region  = var.region
}

resource "aws_security_group" "db" {
  name_prefix = substr(var.db_name, 0, 6)
  description = "Ingress and egress for ${var.db_name} RDS"
  vpc_id      = var.vpc_id
  tags        = merge({ Name = var.db_name }, var.tags)

  ingress {
    description = "db ingress from private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = tolist(var.private_subnet_cidrs)
  }

  # allow ingress from bastion server
  ingress {
    description     = "inbound from bastion server"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    description = "db egress to private subnets"
    self        = true
    from_port   = 22
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = tolist(var.private_subnet_cidrs)
  }
}

// TODO: Add Conditional using var.db_migration_flag
// Pull latest existing snapshot for DB
// data "aws_db_snapshot" "latest_db_snapshot" {
//   db_instance_identifier = var.db_instance_id_migration
//   most_recent            = true
// }

resource "aws_db_snapshot" "test" {
  db_instance_identifier = var.db_instance_id_migration
  db_snapshot_identifier = "terraform-migration"
  tags                   = merge(var.tags, var.datetime)
}

module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 2.0"
  identifier = "${var.db_name}-${var.stage}"

  allow_major_version_upgrade = var.db_allow_major_engine_version_upgrade
  engine                      = "postgres"
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  allocated_storage           = 20

  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  // TODO: Add Conditional using var.db_migration_flag
  // snapshot_identifier = data.aws_db_snapshot.latest_db_snapshot.id
  snapshot_identifier = var.db_snapshot_migration

  vpc_security_group_ids = [aws_security_group.db.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = var.tags

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = tolist(var.private_subnet_ids)

  # DB parameter group
  family = "postgres${var.db_major_version}"

  # DB option group
  major_engine_version = var.db_major_version

  # Database Deletion Protection
  deletion_protection = false
  
}
