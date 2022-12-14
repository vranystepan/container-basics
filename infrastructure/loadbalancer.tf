resource "digitalocean_loadbalancer" "workshop" {
  name   = local.cluster_name
  region = "fra1"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "tcp"

    target_port     = local.http_port
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "tcp"

    target_port     = local.https_port
    target_protocol = "tcp"
  }

  healthcheck {
    port     = local.http_port
    protocol = "tcp"
  }

  droplet_tag = local.cluster_name
}

data "digitalocean_domain" "workshop" {
  name = var.domain
}

resource "digitalocean_record" "workshop_wildcard" {
  domain = data.digitalocean_domain.workshop.id
  type   = "A"
  name   = "*.workshop"
  value  = digitalocean_loadbalancer.workshop.ip
  ttl = 60
}
