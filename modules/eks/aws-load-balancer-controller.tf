
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/../../policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role" "aws_lb_controller_role" {
  name = "${module.eks.cluster_name}-aws-lb-controller"

  assume_role_policy = templatefile("${path.module}/../../roles/aws-load-balancer-controller.json.tpl", {
    oidc_provider_arn = module.eks.oidc_provider_arn
    oidc_provider     = module.eks.oidc_provider
  })
}

resource "aws_iam_policy_attachment" "aws_lb_controller_attach" {
  name       = "aws-lb-controller-attach"
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
  roles      = [aws_iam_role.aws_lb_controller_role.name]
}

## Service Account
resource "kubernetes_service_account" "aws_lb_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller_role.arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller_sa.metadata[0].name
  }

  depends_on = [
    module.eks,
    kubernetes_service_account.aws_lb_controller_sa
  ]
}
