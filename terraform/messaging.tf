resource "aws_sqs_queue" "dead" {
  name                      = "terraform-emulator-dead"
  message_retention_seconds = 345600
}

resource "aws_sqs_queue" "pipe" {
  name = "terraform-emulator-pipe"
}

resource "aws_sqs_queue" "app" {
  name                       = "terraform-emulator"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sns_topic" "app" {
  name              = "terraform-emulator"
  kms_master_key_id = aws_kms_key.app.id
}

resource "aws_sqs_queue_policy" "app" {
  queue_url = aws_sqs_queue.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "FromTopic"
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.app.arn
        Condition = {
          ArnEquals = { "aws:SourceArn" = aws_sns_topic.app.arn }
        }
      },
      {
        Sid       = "FromRule"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.app.arn
        Condition = {
          ArnEquals = { "aws:SourceArn" = aws_cloudwatch_event_rule.app.arn }
        }
      },
    ]
  })
}

resource "aws_sns_topic_subscription" "app" {
  topic_arn            = aws_sns_topic.app.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.app.arn
  raw_message_delivery = true
}
