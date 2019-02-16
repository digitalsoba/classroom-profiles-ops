data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key    = "vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config {
    bucket  = "matabit-terraform-backend"
    region  = "us-west-2"
    key     = "s3/terraform.tfstate"
  }
}