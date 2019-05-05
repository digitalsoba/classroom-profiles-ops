data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key    = "vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "rds" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key    = "rds/terraform.tfstate"
  }
}

data "terraform_remote_state" "spot_instance" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key    = "spot-instance/terraform.tfstate"
  }
}

data "terraform_remote_state" "lightsail" {
  backend = "s3"

  config {
    bucket = "matabit-terraform-backend"
    region = "us-west-2"
    key = "lightsail/terraform.tfstate"
  }
}
