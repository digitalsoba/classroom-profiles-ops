provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "iam/terraform.tfstate"
  }
}

/* Drone CI User/Group */
resource "aws_iam_user" "drone" {
  name = "drone"
}

resource "aws_iam_group" "drone" {
  name = "drone"
}

resource "aws_iam_group_membership" "drone" {
  name  = "drone"
  users = ["${aws_iam_user.drone.id}"]
  group = "${aws_iam_group.drone.name}"
}

/* IAM Policies */
resource "aws_iam_group_policy" "drone-get" {
  name  = "drone-get"
  group = "${aws_iam_group.drone.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::matabit/*"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy" "drone-ecr-push" {
  name  = "drone-ecr-push"
  group = "${aws_iam_group.drone.id}"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"ecr:GetAuthorizationToken",
			"ecr:BatchCheckLayerAvailability",
			"ecr:GetDownloadUrlForLayer",
			"ecr:GetRepositoryPolicy",
			"ecr:DescribeRepositories",
			"ecr:ListImages",
			"ecr:DescribeImages",
			"ecr:BatchGetImage",
			"ecr:InitiateLayerUpload",
			"ecr:UploadLayerPart",
			"ecr:CompleteLayerUpload",
			"ecr:PutImage"
		],
		"Resource": "*"
	}]
}
EOF
}

resource "aws_iam_group_policy" "drone-update-service" {
  name  = "drone-update-service"
  group = "${aws_iam_group.drone.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "application-autoscaling:Describe*",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:RegisterScalableTarget",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "ecs:List*",
      "ecs:Describe*",
      "ecs:UpdateService",
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRoles",
      "iam:ListGroups",
      "iam:ListUsers"
    ],
    "Resource": "*"
  }]
}
EOF
}
