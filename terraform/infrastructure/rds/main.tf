variable "aws_region" {
  default = "us-west-2"
}

variable "password" {
  default = ""
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
    key            = "rds/terraform.tfstate"
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

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "db-sg"
  description = "Allow all traffic to port 3306, mysql"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "TCP"
      description = "MySQL Port open 3306 from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "matabit-dev-db"

  engine                 = "mysql"
  engine_version         = "5.6.41"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_encrypted      = false
  create_db_option_group = false
  publicly_accessible    = true

  username = "dba_matabit"
  password = "${var.password}"
  port     = "3306"

  vpc_security_group_ids = ["${module.db_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = ["${data.terraform_remote_state.vpc.public_subnet_a}", "${data.terraform_remote_state.vpc.public_subnet_b}"]

  # DB parameter group
  family = "mysql5.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "matabit-dev-db"
}