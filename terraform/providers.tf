provider "aws" {
  region = local.region

  # Hard-coded so a missing environment variable cannot fall through to AWS.
  # Every service this stack calls is listed. SSM, EC2, EKS, RDS, and load
  # balancers are not here: the emulator is weak on that path.
  endpoints {
    accessanalyzer   = local.endpoint
    acm              = local.endpoint
    appconfig        = local.endpoint
    cloudtrail       = local.endpoint
    codebuild        = local.endpoint
    codecommit       = local.endpoint
    codedeploy       = local.endpoint
    cognitoidp       = local.endpoint
    ecr              = local.endpoint
    ecs              = local.endpoint
    efs              = local.endpoint
    events           = local.endpoint
    firehose         = local.endpoint
    glue             = local.endpoint
    guardduty        = local.endpoint
    iam              = local.endpoint
    kinesis          = local.endpoint
    kms              = local.endpoint
    lambda           = local.endpoint
    logs             = local.endpoint
    pipes            = local.endpoint
    route53          = local.endpoint
    s3               = local.endpoint
    scheduler        = local.endpoint
    schemas          = local.endpoint
    secretsmanager   = local.endpoint
    servicediscovery = local.endpoint
    ses              = local.endpoint
    sfn              = local.endpoint
    sns              = local.endpoint
    sqs              = local.endpoint
    sts              = local.endpoint
    wafv2            = local.endpoint
    xray             = local.endpoint
  }

  # The certificate is the one the emulator wrote at startup.
  custom_ca_bundle = pathexpand("~/.aws/emulator/9297/ca.pem")

  # The endpoint is an address, so the bucket name has to travel in the path.
  s3_use_path_style = true

  skip_credentials_validation = true
  skip_metadata_api_check     = true

  # Listing bucket tags goes through S3 Control, and that client puts the
  # account id in the hostname. The emulator never sees that request.
  # Skipping the account lookup keeps the tag read on the one listener.
  skip_requesting_account_id = true
}
