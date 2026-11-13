locals {
  endpoint = "https://127.0.0.1:9297"
  region   = "us-east-1"

  # The emulator's own account. This tree has no real account id.
  account_id = "000000000000"

  repository_name = "terraform-emulator"
  bucket_name     = "terraform-emulator-artifacts"
  role_name       = "terraform-emulator-ci"
  policy_name     = "registry-and-bucket"
}
