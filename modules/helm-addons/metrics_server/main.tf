resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls"
      ]
    })
  ]
}
