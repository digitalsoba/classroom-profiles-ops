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
    key            = "lightsail/terraform.tfstate"
  }
}

resource "aws_lightsail_instance" "matabit_dev" {
  name              = "matabit-dev"
  availability_zone = "us-west-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "small_2_0"
  key_pair_name     = "anthony"
}

resource "aws_lightsail_instance" "elk" {
  name              = "elk"
  availability_zone = "us-west-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "medium_2_0"
  key_pair_name     = "anthony"
}

resource "aws_lightsail_static_ip" "matabit_dev" {
  name = "dev.matabit.org"
}

resource "aws_lightsail_static_ip" "elk" {
  name = "elk.matabit.org"
}

resource "aws_lightsail_static_ip_attachment" "matabit_dev" {
  static_ip_name = "${aws_lightsail_static_ip.matabit_dev.name}"
  instance_name  = "${aws_lightsail_instance.matabit_dev.name}"
}

resource "aws_lightsail_static_ip_attachment" "elk" {
  static_ip_name = "${aws_lightsail_static_ip.elk.name}"
  instance_name  = "${aws_lightsail_instance.elk.name}"
}
