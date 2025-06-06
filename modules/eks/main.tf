
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create          = true
  cluster_name    = "${terraform.workspace}-${var.cluster_name}-${var.project}-eks"
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = length(var.ip_access_allow) > 0 ? split(",", join(",", var.ip_access_allow)) : []
  enable_cluster_creator_admin_permissions = true

  cluster_upgrade_policy = {
    support_type = var.upgrade_policy
  }

  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_nodes
      min_size     = var.min_nodes
      max_size     = var.max_nodes

      instance_types = ["t3.medium"]
      ami_type       = "BOTTLEROCKET_x86_64"
      subnet_ids     = var.private_subnet_ids
    }
  }

  cluster_addons = {
    for addon in var.cluster_addons : addon.name => (
      addon.name == "coredns" ? {
        preserve          = true
        addon_version     = addon.version
        resolve_conflicts = "OVERWRITE"
        timeouts          = { create = "30m", delete = "15m" }
        } : {
        preserve          = true
        addon_version     = addon.version
        resolve_conflicts = "OVERWRITE"
        timeouts          = null
      }
    )
  }

  tags = {
    Project     = var.project
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
