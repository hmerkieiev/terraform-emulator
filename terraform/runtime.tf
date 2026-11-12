resource "aws_cloudwatch_log_group" "app" {
  name              = "/terraform-emulator/app"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_bus" "app" {
  name = "terraform-emulator"
}

resource "aws_cloudwatch_event_rule" "app" {
  name           = "terraform-emulator"
  event_bus_name = aws_cloudwatch_event_bus.app.name

  event_pattern = jsonencode({
    source = ["terraform-emulator"]
  })
}

resource "aws_cloudwatch_event_target" "app" {
  rule           = aws_cloudwatch_event_rule.app.name
  event_bus_name = aws_cloudwatch_event_bus.app.name
  arn            = aws_sqs_queue.app.arn
}

resource "aws_sfn_state_machine" "app" {
  name     = "terraform-emulator"
  role_arn = aws_iam_role.service["states"].arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "One succeed state."
    StartAt = "Done"
    States = {
      Done = { Type = "Succeed" }
    }
  })
}

data "archive_file" "app" {
  type        = "zip"
  source_file = "${path.module}/../functions/app/index.py"
  output_path = "${path.module}/.lambda/app.zip"
}

resource "aws_lambda_function" "app" {
  function_name    = "terraform-emulator"
  role             = aws_iam_role.service["lambda"].arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256
  timeout          = 3
  memory_size      = 128
}

resource "aws_scheduler_schedule" "app" {
  name = "terraform-emulator"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 hour)"

  target {
    arn      = aws_sqs_queue.app.arn
    role_arn = aws_iam_role.service["scheduler"].arn
  }
}

# The emulator does check this role before the pipe will start.
resource "aws_iam_role_policy" "pipes" {
  name = "poll-and-publish"
  role = aws_iam_role.service["pipes"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
        ]
        Resource = aws_sqs_queue.pipe.arn
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.app.arn
      },
    ]
  })
}

resource "aws_pipes_pipe" "app" {
  name          = "terraform-emulator"
  role_arn      = aws_iam_role.service["pipes"].arn
  source        = aws_sqs_queue.pipe.arn
  target        = aws_sns_topic.app.arn
  desired_state = "RUNNING"

  depends_on = [aws_iam_role_policy.pipes]

  source_parameters {
    sqs_queue_parameters {
      batch_size = 1
    }
  }
}

resource "aws_ecs_cluster" "app" {
  name = "terraform-emulator"
}
