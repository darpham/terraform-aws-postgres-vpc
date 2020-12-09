provider "aws" {
  version = "3.20.0"
  region  = var.region
}

locals {
  // selects a randoms public subnet to create the bastion in
  subnet_id = element(var.public_subnet_ids, 1)
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
