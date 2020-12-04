variable account_id {
  description = "AWS Account ID"
}

variable vpc_id {
  description = "VPC ID"
}

variable region {
  type    = string
  default = "us-east-2"
}

variable stage {
  type    = string
  default = "dev"
}

variable tags {
  default = {}
  type    = map
}

variable container_port {
  type    = number
  default = 5000
}

variable task_name {
  type    = string
  default = "foodoasis-task"
}

variable public_subnet_ids {

}