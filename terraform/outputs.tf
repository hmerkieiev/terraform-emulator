output "repository_name" {
  value = aws_ecr_repository.app.name
}

output "bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "role_name" {
  value = aws_iam_role.ci.name
}

output "policy_name" {
  value = aws_iam_role_policy.ci.name
}

output "subject" {
  value = local.subject
}
