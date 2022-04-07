#AWS Role for Lambda permissions
resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

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

data "archive_file" "vanity_number_convert_zip" {
  type        = "zip"
  source_dir  = "backend"
  output_path = "vanity_number_convert_function.zip"
}

#Lambda for converting vanity numbers from AWS Connect and writing them to DynamoDB
resource "aws_lambda_function" "vanity_number_convert_lambda" {
  filename         = "vanity_number_convert_function.zip"
  function_name    = "vanity_number_convert_lambda"
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "vanity-number-convert.handler"
  source_code_hash = data.archive_file.vanity_number_convert_zip.output_base64sha256
  runtime          = "nodejs14.x"

  environment {
    variables = {
      VANITY_CHARS         = 4,
      VANITY_NUMBERS_LIMIT = 5,
      DYNAMODB_TABLE       = aws_dynamodb_table.demo_table.name
    }
  }
}

data "archive_file" "vanity_number_get_zip" {
  type        = "zip"
  source_dir  = "backend"
  output_path = "vanity_number_get_function.zip"
}

#Lambda to read vanity numbers from DynamoDB and give them to the FE
resource "aws_lambda_function" "vanity_number_get_lambda" {
  filename         = "vanity_number_get_function.zip"
  function_name    = "vanity_number_get_lambda"
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "vanity-number-get.handler"
  source_code_hash = data.archive_file.vanity_number_get_zip.output_base64sha256
  runtime          = "nodejs14.x"

  environment {
    variables = {
      VANITY_NUMBERS_LIMIT = 5,
      DYNAMODB_TABLE       = aws_dynamodb_table.demo_table.name
    }
  }

}


