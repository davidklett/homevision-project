resource "aws_sqs_queue" "image_dlq" {
  name                      = "${var.project_name}-image-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "text_dlq" {
  name                      = "${var.project_name}-text-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "image_queue" {
  name                       = "${var.project_name}-image-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
}

resource "aws_sqs_queue" "text_queue" {
  name                       = "${var.project_name}-text-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.text_dlq.arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
}

resource "aws_sqs_queue_policy" "image_queue" {
  queue_url = aws_sqs_queue.image_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSNSPublish"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.image_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.upload_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "text_queue" {
  queue_url = aws_sqs_queue.text_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSNSPublish"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.text_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.upload_events.arn
          }
        }
      }
    ]
  })
}
