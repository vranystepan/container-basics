locals {
  cluster_name = "workshop-01"
}

resource "digitalocean_kubernetes_cluster" "workshop" {
  name    = local.cluster_name
  region  = "fra1"
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 3
    auto_scale = false
    tags = [
      local.cluster_name,
    ]
  }
}
