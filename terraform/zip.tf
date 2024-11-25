data "archive_file" "crypto_api" {
  type        = "zip"
  source_file = "../backend/crypto_api.py"
  output_path = "crypto_api.zip"
}

output "crypto_api_path" {
  value = data.archive_file.crypto_api.output_path
}

# --------- # 


data "archive_file" "lambda_function" {
  type        = "zip"
  source_file      = "../backend/lambda_function.py"
  output_path = "viewer_count.zip"
}

output "lambda_function_path" {
  value = data.archive_file.lambda_function.output_path
}

# --------- # 

data "archive_file" "SES_lambda" {
  type        = "zip"
  source_file      = "../backend/SES_lambda.py" 
  output_path = "SES_lambda.zip"
}

output "SES_lambda_path" {
  value = data.archive_file.SES_lambda.output_path
}


