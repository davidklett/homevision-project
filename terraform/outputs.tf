output "upload_bucket_name" {
  value = aws_s3_bucket.upload.id
}

output "upload_bucket_arn" {
  value = aws_s3_bucket.upload.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.upload_events.arn
}

output "image_queue_url" {
  value = aws_sqs_queue.image_queue.url
}

output "text_queue_url" {
  value = aws_sqs_queue.text_queue.url
}

output "image_dlq_url" {
  value = aws_sqs_queue.image_dlq.url
}

output "text_dlq_url" {
  value = aws_sqs_queue.text_dlq.url
}

output "image_processor_function_name" {
  value = aws_lambda_function.image_processor.function_name
}

output "text_processor_function_name" {
  value = aws_lambda_function.text_processor.function_name
}
