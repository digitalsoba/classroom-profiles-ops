terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "ecr_ecs/terraform.tfstate"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_ecr_repository" "matabit_ecr" {
  name = "matabit_ecr"
}
