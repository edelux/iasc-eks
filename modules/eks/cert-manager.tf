
resource "aws_iam_policy" "cert_manager_acm_policy" {
  name        = "cert-manager-acm-policy"
  path        = "/"
  description = "IAM policy for cert-manager to use AWS ACM"

  policy = file("${path.module}/../../policies/cert-manager.json")
}

resource "aws_iam_role" "cert_manager_iam_role" {
  name = "${module.eks.cluster_name}-cert-manager"

  assume_role_policy = templatefile("${path.module}/../../roles/cert-manager.json.tpl", {
    oidc_provider_arn = module.eks.oidc_provider_arn
    oidc_provider     = module.eks.oidc_provider
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager_acm_attach" {
  policy_arn = aws_iam_policy.cert_manager_acm_policy.arn
  role       = aws_iam_role.cert_manager_iam_role.name
}

resource "helm_release" "cert_manager" {
  repository       = "https://charts.jetstack.io"
  name             = "cert-manager"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.17.1"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "extraArgs"
    value = "{--enable-certificate-owner-ref=true}"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager_iam_role.arn
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller
  ]
}
