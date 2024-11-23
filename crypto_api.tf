# ------------------------- Creating a paremeter for the api token ------------------------- #


resource "aws_ssm_parameter" "lambda_btc_api_token" {
  name        = "/lambda/market_cap_api_token"
  description = "API token for fetching BTC value from Coin Market Cap"
  type        = "SecureString"
  value       = var.lambda_btc_api_token
}

# ------------------------- Crypto API lambda + iam role from main.tf ------------------------- #

resource "aws_lambda_function" "crypto_api_function" { 
  filename      = "crypto_api.zip"
  function_name = "crypto_api"
  role          = aws_iam_role.lambda_role.arn
  handler       = "crypto_api.lambda_handler" # must match the code files name
  runtime       = "python3.9"

  layers = [aws_lambda_layer_version.requests_layer.arn]

}

# Lambda Layer Resource
resource "aws_lambda_layer_version" "requests_layer" {
  filename            = "requests-layer.zip"
  layer_name          = "requests_dependency_layer"
  compatible_runtimes = ["python3.9"] # Adjust if you're using a different Python version
  description         = "Lambda Layer containing the requests module"
}

# By default, Lambda functions need permissions to interact with AWS services, not IAM users, that's why the iam role doesn't have iam users attached.

# ------------------------- API Gateway ------------------------- #

# Send CV Resource and Method
resource "aws_api_gateway_resource" "crypto_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.viewer_count_api.id # main rest api for all, (locatted in main.tf) 
  parent_id   = aws_api_gateway_rest_api.viewer_count_api.root_resource_id
  path_part   = "crypto_api"
}

resource "aws_api_gateway_method" "crypto_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.viewer_count_api.id
  resource_id   = aws_api_gateway_resource.crypto_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "crypto_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.viewer_count_api.id
  resource_id             = aws_api_gateway_resource.crypto_api_resource.id
  http_method             = aws_api_gateway_method.crypto_api_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST" # MUST BE POST!
  uri                     = aws_lambda_function.crypto_api_function.invoke_arn
}

# Lambda Permission to API Gateway for crypto_api Lambda
resource "aws_lambda_permission" "api_gateway_crypto_api_permission" {
  statement_id  = "AllowAPIGatewayInvokeCryptoAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crypto_api_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.viewer_count_api.execution_arn}/*/GET/crypto_api"

  depends_on = [
    aws_api_gateway_rest_api.viewer_count_api,
    aws_lambda_function.crypto_api_function
  ]
}

# ------------------------- API Gateway CORS ------------------------- #

// crypto_api gate CORS

resource "aws_api_gateway_method" "crypto_api_options" {
  rest_api_id   = aws_api_gateway_rest_api.viewer_count_api.id
  resource_id   = aws_api_gateway_resource.crypto_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "crypto_api_cors" {
  rest_api_id = aws_api_gateway_rest_api.viewer_count_api.id # main rest api for all, (locatted in main.tf)
  resource_id = aws_api_gateway_resource.crypto_api_resource.id
  http_method = aws_api_gateway_method.crypto_api_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200 
}
EOF
    // Otherwise we would need to write : "application/json" = "{\"statusCode\": 200}"
  }
}