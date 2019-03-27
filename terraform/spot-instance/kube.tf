resource "aws_spot_instance_request" "kube" {
  ami                         = "${var.ami_id}"
  spot_price                  = "0.0069"
  instance_type               = "t3.small"
  key_name                    = "${var.key_name}"
  monitoring                  = false
  associate_public_ip_address = true
  count                       = 3
  wait_for_fulfillment        = true
  user_data                   = "${file("../cloud-init.conf")}"
  security_groups             = ["${module.kube_master_sg.this_security_group_id}","${module.kube_worker_sg.this_security_group_id}"]
  subnet_id                   = "${data.terraform_remote_state.vpc.public_subnet_a}"

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=kube-${count.index}"
  }

  tags {
    Name = "kube"
  }
}