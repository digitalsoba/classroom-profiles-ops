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
    key            = "route53/terraform.tfstate"
  }
}

resource "aws_route53_zone" "zone" {
  name = "matabit.org"
}

resource "aws_route53_record" "ssh" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "ssh"
  type    = "A"
  ttl     = "300"
  records = ["${data.terraform_remote_state.vpc.nat_eip}"]
}

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "db"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.rds_address}"]
}

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "dev"
  type    = "A"
  ttl     = "300"
  records = ["${data.terraform_remote_state.lightsail.matabit_dev_ip}"]
}

resource "aws_route53_record" "prod" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "matabit.org"
  type    = "A"
  ttl     = "300"
  records = ["${data.terraform_remote_state.lightsail.matabit_dev_ip}"]
}

resource "aws_route53_record" "apollo" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "apollo"
  type    = "A"
  ttl     = "300"
  records = ["${data.terraform_remote_state.lightsail.matabit_dev_ip}"]
}
