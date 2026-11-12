resource "aws_secretsmanager_secret" "app" {
  name = "terraform-emulator"
  # No secret version. The stand checks the container, not a stored value.
}

resource "aws_schemas_registry" "app" {
  name = "terraform-emulator"
}

resource "aws_appconfig_application" "app" {
  name = "terraform-emulator"
}

resource "aws_appconfig_environment" "app" {
  name           = "terraform-emulator"
  application_id = aws_appconfig_application.app.id
}

resource "aws_service_discovery_http_namespace" "app" {
  name = "terraform-emulator"
}

resource "aws_kinesis_stream" "app" {
  name = "terraform-emulator"

  # CreateStream already stores 24 hours. Asking for 24 makes the provider
  # call IncreaseStreamRetentionPeriod, which the emulator rejects.
  retention_period = 48

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  # The emulator fills a warm throughput the configuration does not set.
  lifecycle {
    ignore_changes = [warm_throughput_mib_ps]
  }
}

resource "aws_kinesis_firehose_delivery_stream" "app" {
  name        = "terraform-emulator"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.service["firehose"].arn
    bucket_arn = aws_s3_bucket.artifacts.arn
    prefix     = "firehose/"
  }
}

resource "aws_efs_file_system" "app" {
  encrypted  = true
  kms_key_id = aws_kms_key.app.arn
}

resource "aws_xray_group" "app" {
  group_name        = "terraform-emulator"
  filter_expression = "service(\"terraform-emulator\")"
}

resource "aws_route53_zone" "app" {
  name    = local.dns_name
  comment = "Not a delegated zone."
}

resource "aws_acm_certificate" "app" {
  domain_name       = local.dns_name
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ses_domain_identity" "app" {
  domain = local.dns_name
}

resource "aws_cognito_user_pool" "app" {
  name = "terraform-emulator"

  password_policy {
    minimum_length                   = 14
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
}
