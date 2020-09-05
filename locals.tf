locals {
  bastion_name = "bastion-${var.account_id}-${local.namespace}"
  vpc_name     = "main-vpc"
  namespace    = substr(var.project_name, 0, 6)
  db_name      = "${var.project_name}-db"
}
