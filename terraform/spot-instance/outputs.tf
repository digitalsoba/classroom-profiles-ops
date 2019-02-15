output "elk_spot_ip" {
  value = "${aws_spot_instance_request.elk_spot_instance.public_ip}"
}
