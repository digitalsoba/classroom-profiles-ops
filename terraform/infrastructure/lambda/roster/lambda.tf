provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "matabit-terraform-backend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dynamo"
    region         = "us-west-2"
    key            = "lambda/api/roster/terraform.tfstate"
  }
}

resource "aws_iam_role" "read-matabit-api-s3" {
  name        = "read-matabit-api-s3"
  description = "Allow Lambda to read from matabit bucket"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "read-matabit-s3-policy" {
  name = "read-matabit-s3-policy"
  role = "${aws_iam_role.read-matabit-api-s3.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::matabit/api/*",
                "arn:aws:s3:::matabit"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_function" "roster-api" {
  filename      = "lambda_function.py.zip"
  function_name = "terraform-roster-api"
  role          = "${aws_iam_role.read-matabit-api-s3.arn}"
  handler       = "lambda_function.lambda_handler"

  source_code_hash = "${filebase64sha256("lambda_function.py.zip")}"
  runtime          = "python3.7"
}
