terraform {
  required_version = ">= 1.10"

  # Local state on purpose. The emulator keeps resources in memory and
  # drops them when the process stops, so this state belongs to one run.
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0, < 3.0"
    }
  }
}
