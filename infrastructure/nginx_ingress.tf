locals {
  https_port = 32443
  http_port = 32080
}

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = kubernetes_namespace.nginx_ingress.metadata[0].name
  create_namespace = false
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  wait             = true
  atomic           = true

  values = [
    templatefile(
      "${path.module}/assets/nginx_ingress_values.yaml",
      {
        replica_count  = 2,
        memory_request = "256Mi",
        memory_limit   = "256Mi",
        cpu_request    = "100m",
        cpu_limit      = "100m",

        https_port = local.https_port
        http_port = local.http_port
      }
    )
  ]
}