# resource "aws_spot_instance_request" "kube" {
#   ami                         = "${data.aws_ami.ubuntu_18_latest}"
#   spot_price                  = "0.0069"
#   instance_type               = "t3.small"
#   key_name                    = "${var.key_name}"
#   monitoring                  = false
#   associate_public_ip_address = true
#   count                       = 3
#   wait_for_fulfillment        = true
#   user_data                   = "${file("../cloud-init.conf")}"
#   security_groups             = ["${module.kube_master_sg.this_security_group_id}", "${module.kube_worker_sg.this_security_group_id}"]
#   subnet_id                   = "${data.terraform_remote_state.vpc.public_subnet_a}"
#   provisioner "local-exec" {
#     command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=kube-${count.index}"
#   }
#   tags {
#     Name = "kube"
#   }
# }

# module "kube_master_sg" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "kube_master_sg"
#   description = "Security group for Kube admin"
#   vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       description = "All"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       description = "http"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       description = "https"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       description = "ssh"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 6443
#       to_port     = 6443
#       protocol    = "tcp"
#       description = "Kubernetes API server"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 2379
#       to_port     = 2380
#       protocol    = "tcp"
#       description = "etcd server client API"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 10250
#       to_port     = 10250
#       protocol    = "tcp"
#       description = "Kubelet API"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 10251
#       to_port     = 10251
#       protocol    = "tcp"
#       description = "kube-scheduler"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 10252
#       to_port     = 10252
#       protocol    = "tcp"
#       description = "kube-controller-manager"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
# }

# module "kube_worker_sg" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "kube_worker_sg"
#   description = "Security group for Kube admin"
#   vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       description = "All"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       description = "ssh"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 30000
#       to_port     = 32767
#       protocol    = "tcp"
#       description = "NodePort Services"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 10250
#       to_port     = 10250
#       protocol    = "tcp"
#       description = "Kubelet API"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
# }
