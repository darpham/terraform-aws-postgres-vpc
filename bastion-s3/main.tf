provider "aws" {
  version = "3.20.0"
  region  = var.region
}

resource "aws_instance" "bastion" {
 ami                    = "${var.ami}"
 instance_type          = "${var.instance_type}"
 iam_instance_profile   = "${var.iam_instance_profile}"
 subnet_id              = "${var.subnet_id}"
 vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
 user_data              = "${template_file.user_data.rendered}"

 count                  = 1

 tags {
   Name = "${var.name}"
 }
}

module "bastion" {
  source                      = "git::https://github.com/terraform-community-modules/tf_aws_bastion_s3_keys?ref=tags/v2.0.0"
  instance_type               = var.bastion_instance_type
  ami                         = data.aws_ami.ami.id
  eip                         = aws_eip.eip.public_ip
  region                      = var.region
  iam_instance_profile        = aws_iam_instance_profile.s3_readonly.name
  s3_bucket_name              = aws_s3_bucket.ssh_public_keys.id
  vpc_id                      = var.vpc_id
  subnet_ids                  = tolist(var.public_subnet_ids)
  keys_update_frequency       = var.cron_key_update_schedule
  enable_hourly_cron_updates  = true
  apply_changes_immediately   = true
  associate_public_ip_address = true
  ssh_user                    = "ec2-user"
  additional_user_data_script = <<EOF
  printf "============================\n"
  printf "============================\n"
  printf "============================\n"
  printf "============================\n"
  REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  aws ec2 associate-address --region $REGION --instance-id $INSTANCE_ID --allocation-id ${aws_eip.eip.id}
  EOF
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


resource "aws_eip" "eip" {
  vpc = true
}
