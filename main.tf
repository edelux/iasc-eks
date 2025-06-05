
# EKS
module "eks" {
  source             = "./modules/eks"
  max_nodes          = local.max_nodes
  min_nodes          = local.min_nodes
  cluster_name       = local.cluster_name
  desired_nodes      = local.desired_nodes
  cluster_addons     = local.cluster_addons
  upgrade_policy     = local.upgrade_policy
  cluster_version    = local.cluster_version
  vpc_id             = data.terraform_remote_state.infra.outputs.vpc_id
  project            = data.terraform_remote_state.infra.outputs.project
  ip_access_allow    = data.terraform_remote_state.infra.outputs.ip_access_allow
  private_subnet_ids = data.terraform_remote_state.infra.outputs.private_subnet_ids
  zone_id            = values(data.terraform_remote_state.infra.outputs.domain_zone_id)[0]
  domain             = values(data.terraform_remote_state.infra.outputs.domain_zone_name)[0]
}
