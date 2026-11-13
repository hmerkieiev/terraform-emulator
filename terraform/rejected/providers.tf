provider "aws" {
  region = local.region

  # Hard-coded so a missing environment variable cannot fall through to AWS.
  endpoints {
    ecr = local.endpoint
    iam = local.endpoint
    s3  = local.endpoint
    sts = local.endpoint
  }

  custom_ca_bundle            = pathexpand("~/.aws/emulator/9297/ca.pem")
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  # Listing bucket tags goes through S3 Control, and that client puts the
  # account id in the hostname. The emulator never sees that request.
  skip_requesting_account_id = true
}
