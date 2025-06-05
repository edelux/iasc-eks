
## Infra
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket       = "github-eenee2ma9ohxeiquua2ingaipaz6eerahsugheesaen9asa3fee1koor"
    key          = "env:/${terraform.workspace}/infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}




variable "environment" { #REQUIRED
  description = "Environment Name (dev, qa, stg, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(qa|dev|st[ag]|pr[do])[a-z0-9]{0,9}$", var.environment))
    error_message = "The environment name must start with 'dev', 'pro', or 'prd', followed by up to 9 lowercase letters or numbers, with a total length between 3 and 12 characters."
  }

  validation {
    condition     = terraform.workspace == var.environment
    error_message = "Invalid workspace: The active workspace '${terraform.workspace}' does not match the specified environment '${var.environment}'."
  }
}




locals {

  config_file = file("${path.module}/config.yaml")
  config      = yamldecode(local.config_file)

  env_config = local.config.environments[var.environment]

  max_nodes       = local.env_config.infrastructure.max_nodes
  min_nodes       = local.env_config.infrastructure.min_nodes
  cluster_name    = local.env_config.cluster.cluster_name
  desired_nodes   = local.env_config.infrastructure.desired_nodes
  upgrade_policy  = local.env_config.cluster.upgrade_policy
  cluster_version = local.env_config.cluster.cluster_version
  cluster_addons  = local.env_config.cluster.addons
}
