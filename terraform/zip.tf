data "archive_file" "crypto_api" {
  type        = "zip"
  source      = [
    "${path.module}/backend/crypto_api.py",
  ]
  output_path = "${path.root}/crypto_api.zip"
}

output "zip_file_path" {
  value = data.archive_file.crypto_api.output_path
}

# --------- # 


data "archive_file" "lambda_function" {
  type        = "zip"
  source      = [
    "${path.module}/backend/lambda_function.py",
  ]
  output_path = "${path.root}/viewer_count.zip"
}

output "zip_file_path" {
  value = data.archive_file.lambda_function.output_path
}

# --------- # 

data "archive_file" "SES_lambda" {
  type        = "zip"
  source      = [
    "${path.module}/backend/SES_lambda.py",
  ]
  output_path = "${path.root}/SES_lambda.zip"
}

output "zip_file_path" {
  value = data.archive_file.SES_lambda.output_path
}


