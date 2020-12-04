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

variable stage {
  type    = string
  default = "dev"
}

variable vpc_id {
  description = "VPC ID"
}

variable tags {
  default = { terraform_managed = "true" }
  type    = map
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

variable aws_ssm_db_hostname_arn {
  description = "AWS SSM ARN for DB Hostname"
}

variable aws_ssm_db_password_arn {
  description = "AWS SSM ARN for DB Password"
}

variable public_subnet_ids {
  description = "VPB Public Subnets for where to place Fargate tasks"
}

variable db_security_group_id {
  description = "DB Security Groups to allow"
}

variable bastion_security_group_id {
  description = "Bastion security group to allow ingress ssh"
}

variable alb_security_group_id {
  description = "ALB Security Group to allow inbound/outbound traffic"
}

variable alb_target_group_arn {
  description = "ALB Target group for where to place task definitions"
}