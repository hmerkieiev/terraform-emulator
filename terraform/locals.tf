locals {
  # Every service is on this one listener. An IP, not a hostname, so
  # S3 keeps the bucket in the path. The emulator rejects a bucket in the host.
  endpoint = "https://127.0.0.1:9297"
  region   = "us-east-1"

  # The emulator's own account. This tree has no real account id.
  account_id = "000000000000"

  repository_name = "terraform-emulator"
  bucket_name     = "terraform-emulator-artifacts"
  role_name       = "terraform-emulator-ci"
  policy_name     = "registry-and-bucket"

  # Immutable subject GitHub issues for this repository. Repositories
  # created after the 2026-07-15 rollout carry the owner id and the repo id.
  subject = "repo:hmerkieiev@22146499/terraform-emulator@1455920882:ref:refs/heads/main"

  dns_name = "terraform-emulator.test"

  # Roles the other resources name. Each trust is one service, with no condition.
  service_roles = {
    states       = "states.amazonaws.com"
    lambda       = "lambda.amazonaws.com"
    firehose     = "firehose.amazonaws.com"
    scheduler    = "scheduler.amazonaws.com"
    pipes        = "pipes.amazonaws.com"
    codebuild    = "codebuild.amazonaws.com"
    codepipeline = "codepipeline.amazonaws.com"
  }
}
