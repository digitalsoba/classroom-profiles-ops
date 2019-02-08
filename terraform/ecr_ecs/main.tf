terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "ecr_ecs/terraform.tfstate"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_ecr_repository" "matabit_ecr" {
  name = "matabit_ecr"
}

resource "aws_ecs_cluster" "matabit" {
  name = "${var.cluster_name}"
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "matabit-prod" {
  family                   = "matabit-prod"
  container_definitions    = "${file("task-definitions/matabit-dev.json")}"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  task_role_arn            = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  execution_role_arn       = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "prod-service" {
  name            = "prod-service"
  iam_role        = "${aws_iam_role.ecs-service-role.name}"
  cluster         = "${aws_ecs_cluster.matabit.id}"
  task_definition = "${aws_ecs_task_definition.matabit-prod.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
    container_port   = 80
    container_name   = "matabit-dev-container"
  }

  depends_on = [
    "aws_alb.alb",
    "aws_alb_listener.frontend_https"
  ]
}
