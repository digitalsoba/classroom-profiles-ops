# output "elk_spot_ip" {
#   value = "${aws_spot_instance_request.elk_spot_instance.public_ip}"
# }

output "cp_spot_ip" {
  value = "${aws_spot_instance_request.classroom-profiles.public_ip}"
}

# output "apollo_spot_ip" {
#   value = "${aws_spot_instance_request.apollo.public_ip}"
# }

