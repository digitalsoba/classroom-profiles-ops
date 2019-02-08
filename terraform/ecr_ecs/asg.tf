resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                 = "ecs-launch-configuration"
  image_id             = "ami-0d3bd9852d477ade8"
  instance_type        = "t2.medium"
  spot_price           = "0.0139"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${module.alb_sg.this_security_group_id}"]
  associate_public_ip_address = "true"

  user_data = "${file("cloud-init.conf")}"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-autoscaling-group"
  max_size             = "${2}"
  min_size             = "${1}"
  desired_capacity     = "${1}"
  vpc_zone_identifier  = ["${data.terraform_remote_state.vpc.public_subnet_a}", "${data.terraform_remote_state.vpc.public_subnet_a}"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "ELB"
}
