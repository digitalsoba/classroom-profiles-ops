output "matabit_dev_ip" {
  value = "${aws_lightsail_static_ip.matabit_dev.ip_address}"
}

output "elk_ip" {
  value = "${aws_lightsail_static_ip.elk.ip_address}"
}
