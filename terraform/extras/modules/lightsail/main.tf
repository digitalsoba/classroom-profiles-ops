variable "name" {
  description = "Name of the lightsail instance"
}

variable "availability_zone" {
  description = "AZ for the ligthsail instance"
}

variable "blueprint_id" {
  default = "Blueprint ID"
}

variable "bundle_id" {
  default = "Bundle ID"
}

variable "key_pair_name" {
  default = "SSH Key pair for default user"
}

resource "aws_lightsail_instance" "lightsail-module" {
  name              = "${var.name}"
  availability_zone = "${var.availability_zone}"
  blueprint_id      = "${var.blueprint_id}"
  bundle_id         = "${var.bundle_id}"
  key_pair_name     = "${var.key_pair_name}"
}
