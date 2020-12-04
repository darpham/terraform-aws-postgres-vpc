variable account_id {
  description = "AWS Account ID"
}

variable vpc_id {
  description = "VPC ID"
}

variable region {
  type    = string
}

variable stage {
  type    = string
}

variable tags {
  default = { terraform_managed = "true" }
  type    = map
}

variable container_port {
  type    = number
}

variable task_name {
  type    = string
}

variable public_subnet_ids {
  description = "Public Subnets for where the ALB will be associated with"
}