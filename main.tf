
locals {
  yaml_data = yamldecode(file("cluster-ms.yaml"))
  env_data  = lookup(local.yaml_data.environments, var.environment, {})

  max_nodes       = local.env_data.max_nodes
  min_nodes       = local.env_data.min_nodes
  desired_nodes   = local.env_data.desired_nodes
  cluster_version = local.env_data.cluster_version

  addons_versions = lookup(local.env_data, "addons_versions", {})

  cluster_addons = {
    for addon, version in local.addons_versions : addon => {
      preserve          = false
      addon_version     = version
      resolve_conflicts = "OVERWRITE"
    }
  }
}

# EKS
module "eks" {
  source             = "./modules/eks"
  admin_allowed_ips  = var.admin_allowed_ips
  max_nodes          = local.max_nodes
  min_nodes          = local.min_nodes
  desired_nodes      = local.desired_nodes
  cluster_addons     = local.cluster_addons
  cluster_version    = local.cluster_version
  vpc_id             = data.terraform_remote_state.iasc-network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.iasc-network.outputs.private_subnet_ids
  zone_id            = values(data.terraform_remote_state.iasc-network.outputs.domain_zone_id)[0]
  domain             = values(data.terraform_remote_state.iasc-network.outputs.domain_zone_name)[0]
}
