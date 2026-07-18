resource "rancher2_user" "admin" {
  name     = "Default Admin"
  username = "admin"
  password = "dummy"
  enabled  = true

  lifecycle {
    ignore_changes = [password]
  }
}

resource "rancher2_catalog_v2" "bitnami" {
  cluster_id = "local"
  name       = "bitnami"
  url        = "https://charts.bitnami.com/bitnami"
  enabled    = true
}
