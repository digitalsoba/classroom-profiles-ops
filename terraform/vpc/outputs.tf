output "nat_eip" {
  value = "${aws_eip.nat.public_ip}"
}
