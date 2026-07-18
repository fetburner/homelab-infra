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
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.console_kagawa.id
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
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.epgstation.id
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
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k3s.id
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

resource "cloudflare_zero_trust_access_application" "console_kagawa" {
  account_id                 = cloudflare_zone.fetburner_dev.account.id
  name                       = "console-kagawa"
  type                       = "ssh"
  domain                     = "console-kagawa.${cloudflare_zone.fetburner_dev.name}"
  session_duration           = "24h"
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  enable_binding_cookie      = false
  http_only_cookie_attribute = true
  options_preflight_bypass   = false
  destinations = [{
    type = "public"
    uri  = "console-kagawa.${cloudflare_zone.fetburner_dev.name}"
  }]
  policies = [{
    id         = "86b9512c-8921-4b36-8015-e1130853d10d"
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "epgstation_qa" {
  account_id                 = cloudflare_zone.fetburner_dev.account.id
  name                       = "epgstation-qa"
  type                       = "self_hosted"
  domain                     = "epgstation-qa.${cloudflare_zone.fetburner_dev.name}"
  session_duration           = "24h"
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  enable_binding_cookie      = false
  http_only_cookie_attribute = true
  options_preflight_bypass   = false
  destinations = [{
    type = "public"
    uri  = "epgstation-qa.${cloudflare_zone.fetburner_dev.name}"
  }]
  policies = [{
    id         = "36afc495-09a3-4052-a141-a47826c936e6"
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "epgstation" {
  account_id                 = cloudflare_zone.fetburner_dev.account.id
  name                       = "epgstation"
  type                       = "self_hosted"
  domain                     = "epgstation.${cloudflare_zone.fetburner_dev.name}"
  session_duration           = "24h"
  app_launcher_visible       = true
  auto_redirect_to_identity  = false
  enable_binding_cookie      = false
  http_only_cookie_attribute = true
  options_preflight_bypass   = false
  destinations = [{
    type = "public"
    uri  = "epgstation.${cloudflare_zone.fetburner_dev.name}"
  }]
  policies = [{
    id         = "422c3421-2093-4081-8e4b-0cac92a65488"
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "app_launcher" {
  account_id                   = cloudflare_zone.fetburner_dev.account.id
  name                         = "App Launcher"
  type                         = "app_launcher"
  domain                       = "fetburner.cloudflareaccess.com"
  session_duration             = "24h"
  auto_redirect_to_identity    = false
  skip_app_launcher_login_page = false
  landing_page_design = {
    title = "Welcome!"
  }
}

resource "cloudflare_zero_trust_access_policy" "fetburner" {
  account_id       = cloudflare_zone.fetburner_dev.account.id
  decision         = "allow"
  name             = "fetburner"
  session_duration = "24h"
  include = [{
    group = {
      id = cloudflare_zero_trust_access_group.fetburner.id
    }
  }]
}

resource "cloudflare_zero_trust_access_group" "fetburner" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  name       = "fetburner"
  include = [{
    login_method = { id = cloudflare_zero_trust_access_identity_provider.github.id }
  }]
  require = [{
    email = { email = "masayuki3141592@gmail.com" }
  }, {
    geo = { country_code = "JP" }
  }]
}

resource "cloudflare_zero_trust_access_identity_provider" "github" {
  account_id = cloudflare_zone.fetburner_dev.account.id
  name       = "GitHub"
  type       = "github"
  config     = { client_id = "Ov23ctMSHKb1EtXQSNvr" }
  scim_config = {
    enabled                  = false
    identity_update_behavior = "no_action"
    seat_deprovision         = false
    user_deprovision         = false
  }
}