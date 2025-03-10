
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name           = "${terraform.workspace}-eks"
  cluster_version        = var.cluster_version
  cluster_upgrade_policy = "STANDARD"

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.private_subnet_ids

  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = length(var.admin_allowed_ips) > 0 ? split(",", join(",", var.admin_allowed_ips)) : []
  enable_cluster_creator_admin_permissions = true

  cluster_addons = var.cluster_addons

  eks_managed_node_groups = {
    arm64 = {
      desired_size = var.desired_nodes
      min_size     = var.min_nodes
      max_size     = var.max_nodes

      ## instance_types = ["t3a.medium", "t3.medium", "t2.medium"] # amd64
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = ["t4g.medium", "c7g.medium", "m6g.medium"] # arm64 graviton
      capacity_type  = "ON_DEMAND"
      subnet_ids     = var.private_subnet_ids
    }
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
