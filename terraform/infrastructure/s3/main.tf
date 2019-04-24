provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "s3/terraform.tfstate"
  }
}

resource "aws_s3_bucket" "matabit_s3" {
  bucket = "matabit"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "S3 bucket for matabit"
  }
}


