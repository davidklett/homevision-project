resource "aws_sns_topic" "upload_events" {
  name = "${var.project_name}-upload-events"
}

resource "aws_sns_topic_policy" "allow_s3" {
  arn = aws_sns_topic.upload_events.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3Publish"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.upload_events.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.upload.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "image_queue" {
  topic_arn            = aws_sns_topic.upload_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.image_queue.arn
  raw_message_delivery = true
  filter_policy_scope  = "MessageBody"

  filter_policy = jsonencode({
    Records = {
      s3 = {
        object = {
          key = [{ suffix = ".jpg" }, { suffix = ".png" }]
        }
      }
    }
  })
}

resource "aws_sns_topic_subscription" "text_queue" {
  topic_arn            = aws_sns_topic.upload_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.text_queue.arn
  raw_message_delivery = true
  filter_policy_scope  = "MessageBody"

  filter_policy = jsonencode({
    Records = {
      s3 = {
        object = {
          key = [{ suffix = ".txt" }]
        }
      }
    }
  })
}
