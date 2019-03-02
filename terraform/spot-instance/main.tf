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
  ami                         = "${var.ami_id}"
  spot_price                  = "0.0140"
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
resource "aws_spot_instance_request" "cp_dev_server" {
  ami                         = "${var.ami_id}"
  spot_price                  = "0.0040"
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  associate_public_ip_address = true
  count                       = 1
  wait_for_fulfillment        = true
  user_data                   = "${file("../cloud-init.conf")}"
  security_groups             = ["${module.web_server_sg.this_security_group_id}"]
  subnet_id                   = "${data.terraform_remote_state.vpc.public_subnet_a}"

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.cp_dev_server.spot_instance_id} --tags Key=Name,Value=cp-dev-server-${count.index}"
  }

  tags {
    Name = "cp_dev_server"
  }
}

# resource "aws_spot_instance_request" "apollo" {
#   ami                         = "${var.ami_id}"
#   spot_price                  = "0.0040"
#   instance_type               = "t2.micro"
#   key_name                    = "${var.key_name}"
#   monitoring                  = true
#   associate_public_ip_address = true
#   count                       = 1
#   wait_for_fulfillment        = true
#   user_data                   = "${file("../cloud-init.conf")}"
#   security_groups             = ["${module.web_server_sg.this_security_group_id}"]
#   subnet_id                   = "${data.terraform_remote_state.vpc.public_subnet_a}"

#   provisioner "local-exec" {
#     command = "aws ec2 create-tags --resources ${aws_spot_instance_request.apollo.spot_instance_id} --tags Key=Name,Value=apollo-${count.index}"
#   }

#   tags {
#     Name = "apollo"
#   }
# }

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-sg"
  description = "Security group for ELK with HTTPS/Logstash/Kibana/Elasticsearch ports open within VPC"
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
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "elk_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "elk-sg"
  description = "Security group for ELK with HTTPS/Logstash/Kibana/Elasticsearch ports open within VPC"
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
      from_port   = 5044
      to_port     = 5044
      protocol    = "tcp"
      description = "Logstash"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 5601
      to_port     = 5601
      protocol    = "tcp"
      description = "Kibana"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}