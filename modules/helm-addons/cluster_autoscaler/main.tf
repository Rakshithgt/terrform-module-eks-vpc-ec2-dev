data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "autoscaler_irsa" {
  name               = "${var.env}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json
}

resource "aws_iam_role_policy_attachment" "autoscaler_attach" {
  role       = aws_iam_role.autoscaler_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "kubernetes_service_account" "autoscaler_sa" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.autoscaler_irsa.arn
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = var.cluster_name
      }
      rbac = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.autoscaler_sa.metadata[0].name
        }
      }
    })
  ]

  depends_on = [kubernetes_service_account.autoscaler_sa]
}
