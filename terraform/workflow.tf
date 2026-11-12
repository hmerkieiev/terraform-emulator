resource "aws_codecommit_repository" "app" {
  repository_name = "terraform-emulator"
  description     = "Repository shape checked against the emulator."
}

resource "aws_codedeploy_app" "app" {
  name             = "terraform-emulator"
  compute_platform = "Lambda"
}

resource "aws_codebuild_project" "app" {
  name         = "terraform-emulator"
  service_role = aws_iam_role.service["codebuild"].arn

  source {
    type      = "NO_SOURCE"
    buildspec = "version: 0.2\nphases:\n  build:\n    commands:\n      - 'true'\n"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }
}

resource "aws_codepipeline" "app" {
  name     = "terraform-emulator"
  role_arn = aws_iam_role.service["codepipeline"].arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        S3Bucket    = aws_s3_bucket.artifacts.bucket
        S3ObjectKey = "source.zip"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.app.name
      }
    }
  }
}
