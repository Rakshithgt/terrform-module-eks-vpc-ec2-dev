resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}
