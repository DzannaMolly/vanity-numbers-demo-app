#Permission for Api Gateway to execute for Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.vanity_number_get_lambda.function_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.test_api.id}/*/${aws_api_gateway_method.test_method.http_method}/${aws_api_gateway_resource.test_resource.path_part}"
}

#Create Api Gateway Rest Api
resource "aws_api_gateway_rest_api" "test_api" {
  name        = "TestAPI"
  description = "This is the Test API"
}

#Create Api Gateway Resource
resource "aws_api_gateway_resource" "test_resource" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  parent_id   = aws_api_gateway_rest_api.test_api.root_resource_id
  path_part   = "test"
}

#Provides a HTTP Method for an API Gateway Resource
resource "aws_api_gateway_method" "test_method" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.test_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

#Provides an HTTP Method Integration for an API Gateway Integration
resource "aws_api_gateway_integration" "test_integration" {
  rest_api_id             = aws_api_gateway_rest_api.test_api.id
  resource_id             = aws_api_gateway_resource.test_resource.id
  http_method             = aws_api_gateway_method.test_method.http_method
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.account_id}:function:${aws_lambda_function.vanity_number_get_lambda.function_name}/invocations"
  integration_http_method = "POST"
}

#Provides an HTTP Method Response for an API Gateway Resource
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_resource.id
  http_method = aws_api_gateway_integration.test_integration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

#Provides an HTTP Method Integration Response for an API Gateway Resource
resource "aws_api_gateway_integration_response" "test_response_integration" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.test_resource.id
  http_method = aws_api_gateway_method.test_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code
  depends_on = [
    aws_api_gateway_integration.test_integration
  ]

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.test_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.test_method
  ]
}

#
# Domain Setup
#Registers a custom domain name for use with AWS API Gateway

resource "aws_api_gateway_domain_name" "example" {
  domain_name              = aws_acm_certificate.example.domain_name
  regional_certificate_arn = aws_acm_certificate.example.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = aws_api_gateway_rest_api.test_api.id
  domain_name = aws_api_gateway_domain_name.example.domain_name
  stage_name  = "example"

  depends_on = [
    aws_api_gateway_deployment.example,
    aws_api_gateway_stage.example
  ]
}