resource "aws_connect_instance" "test" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = "vanity-numbers-connect"
  outbound_calls_enabled   = true
}

resource "aws_connect_lambda_function_association" "vanity_number_convert_lambda_association" {
  function_arn = aws_lambda_function.vanity_number_convert_lambda.arn
  instance_id  = aws_connect_instance.test.id
}