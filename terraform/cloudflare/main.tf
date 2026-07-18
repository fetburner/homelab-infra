resource "cloudflare_zone" "fetburner_dev" {
  account = {
    id = "abdb81a14388bfb3b2ccfe00525c16df"
  }
  name = "fetburner.dev"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "console_kagawa" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  config_src = "cloudflare"
  name       = "console-kagawa"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "epgstation" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  config_src = "cloudflare"
  name       = "epgstation"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "k3s" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  config_src = "cloudflare"
  name       = "k3s"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "console_kagawa" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  tunnel_id  = "e795f54d-0905-4821-8959-4abd659f8d42"
  config = {
    ingress = [
      {
        hostname       = "console-kagawa.${cloudflare_zone.fetburner_dev.name}"
        service        = "ssh://localhost:22"
        origin_request = {}
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "epgstation" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  tunnel_id  = "6491c854-dd08-447f-9a31-a8066f197dec"
  config = {
    ingress = [
      {
        hostname       = "epgstation.${cloudflare_zone.fetburner_dev.name}"
        service        = "http://nginx:80"
        origin_request = {}
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "k3s" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  tunnel_id  = "87e9ac1d-2811-4771-938a-0085766308b2"
  config = {
    ingress = [
      {
        hostname       = "epgstation-qa.${cloudflare_zone.fetburner_dev.name}"
        service        = "http://nginx.epgstation.svc.cluster.local"
        origin_request = {}
      },
      {
        hostname       = "rancher.${cloudflare_zone.fetburner_dev.name}"
        service        = "http://rancher.cattle-system.svc.cluster.local"
        origin_request = {}
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

resource "cloudflare_dns_record" "mx_route1" {
  content  = "route1.mx.cloudflare.net"
  name     = cloudflare_zone.fetburner_dev.name
  priority = 98
  proxied  = false
  tags     = []
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.fetburner_dev.id
  settings = {}
}

resource "cloudflare_dns_record" "mx_route2" {
  content  = "route2.mx.cloudflare.net"
  name     = cloudflare_zone.fetburner_dev.name
  priority = 76
  proxied  = false
  tags     = []
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.fetburner_dev.id
  settings = {}
}

resource "cloudflare_dns_record" "mx_route3" {
  content  = "route3.mx.cloudflare.net"
  name     = cloudflare_zone.fetburner_dev.name
  priority = 27
  proxied  = false
  tags     = []
  ttl      = 1
  type     = "MX"
  zone_id  = cloudflare_zone.fetburner_dev.id
  settings = {}
}

resource "cloudflare_dns_record" "txt_spf" {
  content  = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  name     = cloudflare_zone.fetburner_dev.name
  proxied  = false
  tags     = []
  ttl      = 1
  type     = "TXT"
  zone_id  = cloudflare_zone.fetburner_dev.id
  settings = {}
}

resource "cloudflare_dns_record" "txt_dkim" {
  content  = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\""
  name     = "cf2024-1._domainkey.${cloudflare_zone.fetburner_dev.name}"
  proxied  = false
  tags     = []
  ttl      = 1
  type     = "TXT"
  zone_id  = cloudflare_zone.fetburner_dev.id
  settings = {}
}

resource "cloudflare_email_routing_rule" "forward_me" {
  enabled  = true
  name     = "Rule created at 2024-07-01T15:12:56.526Z"
  priority = 0
  zone_id  = cloudflare_zone.fetburner_dev.id
  actions = [{
    type  = "forward"
    value = ["masayuki3141592@gmail.com"]
  }]
  matchers = [{
    field = "to"
    type  = "literal"
    value = "me@${cloudflare_zone.fetburner_dev.name}"
  }]
}