data "archive_file" "tidal_s3_event_handler_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = local.archive_output_path
}

resource "aws_lambda_function" "tidal_s3_event_handler" {
  timeout          = 60
  memory_size      = 512
  runtime          = "nodejs12.x"
  handler          = "index.handler"
  function_name    = local.function_name
  filename         = local.archive_output_path
  role             = "arn:aws:iam::594206825329:role/lambda-all"
  depends_on       = [aws_cloudwatch_log_group.tidal_s3_event_handler]
  source_code_hash = data.archive_file.tidal_s3_event_handler_zip.output_base64sha256

  vpc_config {
    security_group_ids = [
      "sg-0370122acfac20fd8",
    ]
    subnet_ids = [
      "subnet-05118fa49fa1cd19e",
      "subnet-0720fb8390bdfd4c4",
      "subnet-0de5d84f8ec696cf8"
    ]
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      TIDAL_TABLE = "tidal-${var.env}"
    }
  }
}

resource "aws_cloudwatch_log_group" "tidal_s3_event_handler" {
  retention_in_days = 7
  name              = "/aws/lambda/${local.function_name}"
}
