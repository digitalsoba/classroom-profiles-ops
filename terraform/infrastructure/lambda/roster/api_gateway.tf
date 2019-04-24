# API Gateway
resource "aws_api_gateway_rest_api" "roster" {
  name        = "terraform-roster-api"
  description = "Mock Roster API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "roster" {
  path_part   = "roster"
  parent_id   = "${aws_api_gateway_rest_api.roster.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.roster.id}"
}

resource "aws_api_gateway_method" "roster" {
  rest_api_id   = "${aws_api_gateway_rest_api.roster.id}"
  resource_id   = "${aws_api_gateway_resource.roster.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "roster" {
  rest_api_id             = "${aws_api_gateway_rest_api.roster.id}"
  resource_id             = "${aws_api_gateway_resource.roster.id}"
  http_method             = "${aws_api_gateway_method.roster.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.roster-api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    "aws_api_gateway_integration.roster",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.roster.id}"
  stage_name  = "api"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.roster-api.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.roster.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
