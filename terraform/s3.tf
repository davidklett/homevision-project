resource "aws_s3_bucket" "upload" {
  bucket = "${var.project_name}-upload-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_notification" "upload_events" {
  bucket = aws_s3_bucket.upload.id

  topic {
    topic_arn = aws_sns_topic.upload_events.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
