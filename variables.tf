// --------------------------
// Global/General Variables
// --------------------------
variable account_id {
  description = "AWS Account ID"
}

variable region {
  type    = string
  default = "us-east-2"
}

variable project_name {
  description = "The overall name of the project using this infrastructure; used to group related resources by"
}

variable stage {
  type    = string
  default = "dev"
}

variable tags {
  default = { terraform_managed = "true" }
  type    = map
}

variable cidr_block {
  default     = "10.10.0.0/16"
  description = "The range of IP addresses this vpc will reside in"
}

variable availability_zones {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "us-east-2a",
    "us-east-2b"
    ]
}

// --------------------------
// ECS/Fargat Variables
// --------------------------
variable container_cpu {
  type    = number
  default = 256
}

variable container_memory {
  type    = number
  default = 512
}

variable container_port {
  type    = number
  default = 5000
}

variable task_name {
  type    = string
  default = "foodoasis-task"
}

variable health_check_path {
  type    = string
  default = "/health"
}

variable container_name {
  default = "foodoasis-container"
  type    = string
}

variable cluster_name {
  default = "foodoasis-cluster"
  type    = string
}

variable image_tag {
  description = "tag to be used for elastic container repositry image"
  default = "latest"
}

variable desired_count {
  default = 1
  type    = number
}

// --------------------------
// RDS/Database Variables
// --------------------------
variable db_name {
  description = "Name of the Database"
}
variable db_username {
  description = "Databse Username"
}
variable db_password {
  description = "Databse Password"
}

// DB Migration Variables (Under construction)
variable db_instance_id_migration {
  description = "The database ID from which the new database will start using the latest snapshot"
  default     = "na"
}

variable db_instance_region_migration {
  description = "The database ID from which the new database will start using the latest snapshot"
  default     = "na"
}

variable db_snapshot_migration {
  description = "Name of snapshot that will used to for new database"
  default     = "na"
}

// --------------------------
// Bastion Module Variables
// --------------------------
variable bastion_name {}
// variable namespace {}

variable bastion_instance_type {
  description = "The ec2 instance type of the bastion server"
  default     = "t2.micro"
}

variable cron_key_update_schedule {
  default     = "5,0,*,* * * * *"
  description = "The cron schedule that public keys are synced from the bastion s3 bucket to the server; default to once every hour"
}

variable ssh_public_key_names {
  description = "the name of the public key files in AWS S3 ./public_keys without the file extension; example ['alice', 'bob', 'carol']"
  type        = list(string)
}