resource "aws_lambda_function" "image_processor" {
  function_name    = "${var.project_name}-image-processor"
  role             = aws_iam_role.image_processor.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = data.archive_file.image_processor.output_path
  source_code_hash = data.archive_file.image_processor.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME      = aws_s3_bucket.upload.id
      HOUSES_PREFIX    = "Houses/"
      METRIC_NAMESPACE = "HomeVision"
    }
  }
}

resource "aws_lambda_event_source_mapping" "image_queue" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.image_processor.arn
  batch_size       = 1
}

resource "aws_lambda_function" "text_processor" {
  function_name    = "${var.project_name}-text-processor"
  role             = aws_iam_role.text_processor.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = data.archive_file.text_processor.output_path
  source_code_hash = data.archive_file.text_processor.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME      = aws_s3_bucket.upload.id
      US_PREFIX        = "us-addresses/"
      NON_US_PREFIX    = "non-us-addresses/"
      METRIC_NAMESPACE = "HomeVision"
    }
  }
}

resource "aws_lambda_event_source_mapping" "text_queue" {
  event_source_arn = aws_sqs_queue.text_queue.arn
  function_name    = aws_lambda_function.text_processor.arn
  batch_size       = 1
}
