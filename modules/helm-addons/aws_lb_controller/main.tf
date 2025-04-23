data "aws_iam_policy_document" "lb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller_irsa" {
  name               = "${var.env}-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.lb_assume_role.json
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.env}-AWSLoadBalancerController"
  description = "IAM policy for LB controller"
  policy      = file("${path.module}/lb-policy.json") # You’ll need this policy file!
}

resource "aws_iam_role_policy_attachment" "lb_attach" {
  role       = aws_iam_role.lb_controller_irsa.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

resource "kubernetes_service_account" "lb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_irsa.arn
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.lb_sa.metadata[0].name
      }
    })
  ]

  depends_on = [kubernetes_service_account.lb_sa]
}
