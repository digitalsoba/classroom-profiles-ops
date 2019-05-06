provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "vpc/terraform.tfstate"
  }
}

# VPC
resource "aws_vpc" "matabit_vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpc_name}"
  }
}

## Public Subnet A
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = "${aws_vpc.matabit_vpc.id}"
  cidr_block              = "${var.public_cidr_a}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.public_az_a}"

  tags {
    Name = "${var.public-subnet-name-a}"
  }
}

## Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = "${aws_vpc.matabit_vpc.id}"
  cidr_block              = "${var.public_cidr_b}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.public_az_b}"

  tags {
    Name = "${var.public-subnet-name-b}"
  }
}

## Private Subnet A
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = "${aws_vpc.matabit_vpc.id}"
  cidr_block              = "${var.private_cidr_a}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.private_az_a}"

  tags {
    Name = "${var.private-subnet-name-a}"
  }
}

## Private Subnet B
resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = "${aws_vpc.matabit_vpc.id}"
  cidr_block              = "${var.private_cidr_b}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.private_az_b}"

  tags {
    Name = "${var.private-subnet-name-b}"
  }
}

# Define NAT Instance SG
resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.matabit_vpc.id}"

  tags {
    Name = "NAT-SG"
  }
}

# Create NAT instance
resource "aws_instance" "nat" {
  ami                         = "ami-40d1f038"                     # this is a special ami preconfigured to do NAT
  availability_zone           = "us-west-2a"
  instance_type               = "t2.micro"
  key_name                    = "anthony"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  subnet_id                   = "${aws_subnet.public_subnet_a.id}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${file("../cloud-init.conf")}"

  tags {
    Name = "VPC-NAT"
  }
}

# Give NAT instance an EIP
resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc      = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.matabit_vpc.id}"

  tags {
    Name = "VPC IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.matabit_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${aws_vpc.matabit_vpc.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }

  tags {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_rt_b" {
  subnet_id      = "${aws_subnet.public_subnet_b.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "private-rt-a" {
  subnet_id      = "${aws_subnet.private_subnet_a.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}

resource "aws_route_table_association" "private-rt-b" {
  subnet_id      = "${aws_subnet.private_subnet_b.id}"
  route_table_id = "${aws_route_table.private_rt.id}"
}
