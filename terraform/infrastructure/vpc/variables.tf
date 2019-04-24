### Variables ###
variable "aws_region" {
  default = "us-west-2"
}

## VPC and NAT ##
variable "vpc_cidr_block" {
  description = "The IPv4 CIDR to be used for the VPC"
  default     = "172.31.0.0/16"
}

variable "vpc_name" {
  description = "The name that will be associated with the VPC"
  default     = "matabit-vpc"
}

variable "gateway_name" {
  description = "The name that will be associated with the Internet Gateway"
  default     = "matabit-nat-gateway"
}

## Subnet settings ##

# Public subnet A
variable "public_cidr_a" {
  description = "The CIDR that will be associated with the Public Subnet"
  default     = "172.31.1.0/24"
}

variable "public_az_a" {
  default = "us-west-2a"
}

variable "public-subnet-name-a" {
  default = "public-a"
}

# Public Subnet B
variable "public_cidr_b" {
  description = "The CIDR that will be associated with the Public Subnet"
  default     = "172.31.2.0/24"
}

variable "public_az_b" {
  default = "us-west-2b"
}

variable "public-subnet-name-b" {
  default = "public-b"
}

# Private Subnet A
variable "private_cidr_a" {
  description = "The CIDR that will be associated with the Public Subnet"
  default     = "172.31.3.0/24"
}

variable "private_az_a" {
  default = "us-west-2a"
}

variable "private-subnet-name-a" {
  default = "private-a"
}

# Private Subnet B
variable "private_cidr_b" {
  description = "The CIDR that will be associated with the Public Subnet"
  default     = "172.31.4.0/24"
}

variable "private_az_b" {
  default = "us-west-2b"
}

variable "private-subnet-name-b" {
  default = "private-b"
}
