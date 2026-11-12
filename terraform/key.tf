# The root statement is the key-admin pattern AWS requires on a key policy.
# Resource "*" here is the key itself, which is not known until the key exists.
resource "aws_kms_key" "app" {
  description             = "Key for the emulator stand."
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "Root"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })
}

resource "aws_kms_alias" "app" {
  name          = "alias/terraform-emulator"
  target_key_id = aws_kms_key.app.key_id
}
