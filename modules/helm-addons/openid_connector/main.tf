resource "kubernetes_config_map" "openid_config" {
  metadata {
    name      = "oidc-connector"
    namespace = "kube-system"
  }

  data = {
    "client-id"     = var.client_id
    "client-secret" = var.client_secret
    "issuer-url"    = var.issuer_url
  }
}
