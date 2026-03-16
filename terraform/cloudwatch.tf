resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Business metrics (stat widgets)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 4
        properties = {
          title  = "Houses Detected"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["HomeVision", "HousesDetected"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 4
        properties = {
          title  = "US Addresses"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["HomeVision", "USAddresses"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 4
        properties = {
          title  = "Non-US Addresses"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["HomeVision", "NonUSAddresses"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 4
        properties = {
          title  = "Total Files Processed"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["HomeVision", "ImagesProcessed", { id = "m1", visible = false }],
            ["HomeVision", "TextFilesProcessed", { id = "m2", visible = false }],
            [{ expression = "m1 + m2", label = "Total Files", id = "total" }]
          ]
        }
      },

      # Row 2: DLQ and errors
      {
        type   = "metric"
        x      = 0
        y      = 4
        width  = 8
        height = 6
        properties = {
          title  = "DLQ Messages"
          region = var.aws_region
          stat   = "Maximum"
          period = 300
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.image_dlq.name, { id = "m1", label = "Image DLQ" }],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.text_dlq.name, { id = "m2", label = "Text DLQ" }],
            [{ expression = "m1 + m2", label = "Total DLQ", id = "total" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 4
        width  = 8
        height = 6
        properties = {
          title  = "Lambda Errors"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.image_processor.function_name, { label = "Image Processor" }],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.text_processor.function_name, { label = "Text Processor" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 4
        width  = 8
        height = 6
        properties = {
          title  = "Lambda Invocations"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.image_processor.function_name, { label = "Image Processor" }],
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.text_processor.function_name, { label = "Text Processor" }]
          ]
        }
      },

      # Row 3: Operational metrics
      {
        type   = "metric"
        x      = 0
        y      = 10
        width  = 8
        height = 6
        properties = {
          title  = "Processing Over Time"
          region = var.aws_region
          stat   = "Sum"
          period = 300
          metrics = [
            ["HomeVision", "HousesDetected", { label = "Houses" }],
            ["HomeVision", "ImagesWithNoHouse", { label = "Non-House Images" }],
            ["HomeVision", "USAddresses", { label = "US Addresses" }],
            ["HomeVision", "NonUSAddresses", { label = "Non-US Addresses" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 10
        width  = 8
        height = 6
        properties = {
          title  = "Lambda Duration (ms)"
          region = var.aws_region
          period = 300
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.image_processor.function_name, { label = "Image p50", stat = "p50" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.image_processor.function_name, { label = "Image p99", stat = "p99" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.text_processor.function_name, { label = "Text p50", stat = "p50" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.text_processor.function_name, { label = "Text p99", stat = "p99" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 10
        width  = 8
        height = 6
        properties = {
          title  = "SQS Queue Depth"
          region = var.aws_region
          stat   = "Maximum"
          period = 300
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.image_queue.name, { label = "Image Queue" }],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.text_queue.name, { label = "Text Queue" }]
          ]
        }
      }
    ]
  })
}
