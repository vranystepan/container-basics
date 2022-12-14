resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  create_namespace = false
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  wait             = true
  atomic           = true

  values = [
    templatefile(
      "${path.module}/assets/cert_manager_values.yaml",
      {}
    )
  ]
}

resource "helm_release" "cert_manager_issuer" {
  name             = "issuer"
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  create_namespace = false
  chart            = "${path.module}/assets/issuers"
  wait             = true
  atomic           = true

  values = [
    templatefile(
      "${path.module}/assets/issuers_values.yaml",
      {
        email = var.email
      }
    )
  ]

  depends_on = [
    helm_release.cert_manager,
  ]
}