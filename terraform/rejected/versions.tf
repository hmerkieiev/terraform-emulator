terraform {
  required_version = ">= 1.10"

  # Local state on purpose. This stack is applied once, then the check refuses it.
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}
