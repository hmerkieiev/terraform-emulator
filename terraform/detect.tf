resource "aws_s3_bucket" "trail" {
  bucket = "terraform-emulator-trail"
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket                  = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Acl"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.trail.arn
      },
      {
        Sid       = "Write"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.trail.arn}/AWSLogs/${local.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
    ]
  })
}

resource "aws_cloudtrail" "app" {
  name                          = "terraform-emulator"
  s3_bucket_name                = aws_s3_bucket.trail.id
  enable_log_file_validation    = true
  include_global_service_events = true

  depends_on = [aws_s3_bucket_policy.trail]
}

resource "aws_guardduty_detector" "app" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
}

resource "aws_accessanalyzer_analyzer" "app" {
  analyzer_name = "terraform-emulator"
  type          = "ACCOUNT"
}

resource "aws_wafv2_web_acl" "app" {
  name  = "terraform-emulator"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "terraform-emulator"
    sampled_requests_enabled   = false
  }
}
