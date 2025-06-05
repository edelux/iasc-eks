
# AWS Provider
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

terraform {
  backend "s3" {}
}

provider "aws" {
  region = data.terraform_remote_state.infra.outputs.region
}
