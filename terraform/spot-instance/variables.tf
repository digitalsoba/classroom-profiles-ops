data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}
variable "ami_id" {
  description = "AMI ID for spot instance (ubuntu 18.04 us-west-2)"
  default     = "${data.aws_ami.ubuntu.name}"
}

variable "key_name" {
  default = "anthony"
}
