resource "aws_api_gateway_rest_api" "roster-api" {
  name = "roster-api"
}

resource "aws_api_gateway_resource" "roster-api-resource" {
  path_part   = "resource"
  parent_id   = "${aws_api_gateway_rest_api.roster-api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.roster-api.id}"
}

resource "aws_api_gateway_method" "roster-api-method" {
  rest_api_id   = "${aws_api_gateway_resource.roster-api-resource.id}"
  resource_id   = "${aws_api_gateway_resource.roster-api-resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}