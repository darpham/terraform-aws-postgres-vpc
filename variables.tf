variable project_name {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable db_instance_id_migration {
  description = "The database ID from which the new database will start using the latest snapshot"
}

variable db_instance_region_migration {
  description = "The database ID from which the new database will start using the latest snapshot"
}

variable db_snapshot_migration {
  description = "Name of snapshot that will used to for new database"
}

variable db_migration_flag {
  description = "Flag to determine if new RDS instance will pull data from snapshot"
  default = 1
}

variable allowed_security_groups {
  description = "security group ids that are allowed to the bastion server"
  type        = list(string)
  default     = []
}

variable bastion_instance_type {
  description = "The ec2 instance type of the bastion server"
  default     = "t2.small"
}

variable account_id {
  description = "the aws account id # that this is provisioned into"
}
variable stage {
  description = "a short name describing the lifecyle or stage of development that this is running for; ex: 'dev', 'qa', 'prod', 'test'"
}
variable region {
  description = "the aws region code where this is deployed; ex: 'us-west-2', 'us-east-1', 'us-east-2'"
}

variable cron_key_update_schedule {
  default     = "5,0,*,* * * * *"
  description = "The cron schedule that public keys are synced from the bastion s3 bucket to the server; default to once every hour"
}

variable cidr_block {
  default     = "10.10.0.0/16"
  description = "The range of IP addresses this vpc will reside in"
}

variable availability_zones {
  type        = list(string)
  description = "The region + identifiers for the zones that the vpc will cover. Ex: ['us-west-2a', 'us-west-2b', 'us-west-2c']. Varies between regions."
}

variable tags {
  default = { terraform_managed = "true" }
  type    = map
}

variable db_username {
  description = "The name of the default postgres user created by RDS when the instance is booted"
}

variable db_name {
  description = "The name of the default postgres database created by RDS when the instance is booted"
}
variable db_password {
  description = "The postgres database password created for the default database when the instance is booted"
}
variable db_instance_class {
  description = "The instance type of the db; defaults to db.t2.small"
  default     = "db.t2.small"
}
variable db_engine_version {
  description = "the semver major and minor version of postgres; default to 11.8"
  default = "11.8"
}
variable db_allow_major_engine_version_upgrade {
  default = true
}

variable db_major_version {
  default = "11"
}

variable ssh_public_key_names {
  description = "the name of the public key files in ./public_keys without the file extension; example ['alice', 'bob', 'carol']"
  type        = list(string)
}
