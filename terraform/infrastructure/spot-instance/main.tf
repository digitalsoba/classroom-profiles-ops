variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "spot-instance/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key    = "vpc/terraform.tfstate"
  }
}

resource "aws_spot_instance_request" "elk_spot_instance" {
  ami                         = "${data.aws_ami.ubuntu_18_latest.id}"
  spot_price                  = "0.02"
  instance_type               = "t2.medium"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  associate_public_ip_address = true
  count                       = 1
  wait_for_fulfillment        = true
  user_data                   = "${file("../cloud-init.conf")}"
  security_groups             = ["${module.elk_sg.this_security_group_id}"]
  subnet_id                   = "${data.terraform_remote_state.vpc.public_subnet_a}"

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.elk_spot_instance.spot_instance_id} --tags Key=Name,Value=elk-server-${count.index}"
  }

  tags {
    Name = "elk-server"
  }
}