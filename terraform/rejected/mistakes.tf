# Each value below is a mistake. The emulator applies the stack.
# scripts/check has to refuse it, and name the mistake.

resource "aws_ecr_repository" "app" {
  name                 = local.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_iam_role" "ci" {
  name        = local.role_name
  description = "Widened on purpose. The check reads this document back."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "*"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:aud" = "*"
          "token.actions.githubusercontent.com:sub" = "*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "ci" {
  name = local.policy_name
  role = aws_iam_role.ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "TooWide"
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "*"
    }]
  })
}
