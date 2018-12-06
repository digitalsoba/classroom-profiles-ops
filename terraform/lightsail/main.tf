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

module "lightsail_dev" {
  source            = "../modules/lightsail"
  lightsail_name    = "matabit-dev"
  availability_zone = "us-west-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "nano_2_0"
  key_pair_name     = "anthony"
}
