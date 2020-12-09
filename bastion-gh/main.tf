provider "aws" {
  version = "3.20.0"
  region  = var.region
}

locals {
  // selects a randoms public subnet to create the bastion in
  subnet_id = element(var.public_subnet_ids, 1)
}

resource "aws_security_group" "bastion" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags = {
    Name = var.name
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr
  ipv6_cidr_blocks  = var.allowed_ipv6_cidr
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "ssh_sg_ingress" {
  count                    = length(var.allowed_security_groups)
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_all_egress" {
  type      = "egress"
  from_port = "0"
  to_port   = "65535"
  protocol  = "all"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  ipv6_cidr_blocks = [
    "::/0",
  ]

  security_group_id = aws_security_group.bastion.id
}

data "template_file" "user_data" {
  template = file("${path.module}/${var.user_data_file}")

  vars = {
    // s3_bucket_name              = var.s3_bucket_name
    // s3_bucket_uri               = var.s3_bucket_uri
    ssh_user                    = var.ssh_user
    keys_update_frequency       = var.keys_update_frequency
    enable_hourly_cron_updates  = var.enable_hourly_cron_updates
    // additional_user_data_script = var.additional_user_data_script
  }
}

resource "aws_instance" "bastion" {
 ami                    = aws_ami.ami.id
 instance_type          = var.instance_type
 subnet_id              = local.subnet_id
 vpc_security_group_ids = [aws_security_group.bastion.id]
 user_data              = "${template_file.user_data.rendered}"

 count                  = 1

 tags {
   Name = "${var.name}"
 }
}

data "aws_ami" "ami" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*.x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

// resource "aws_eip" "eip" {
//   vpc = true
// }
