data alicloud_ram_users "default" {
  name_regex = "tf-example"
}

data alicloud_cs_managed_kubernetes_clusters "default" {
  name_regex = "tf-example"
}

resource "alicloud_cs_kubernetes_permissions" "default" {
  uid = data.alicloud_ram_users.default.users.0.id
  permissions {
    cluster     = ""
    role_type   = "all-clusters"
    role_name   = "dev"
    namespace   = ""
    is_custom   = false
    is_ram_role = false
  }
  permissions {
    cluster     = data.alicloud_cs_managed_kubernetes_clusters.default.clusters.0.id
    role_type   = "cluster"
    role_name   = "ops"
    namespace   = ""
    is_custom   = false
    is_ram_role = false
  }
}

resource "alicloud_cs_kubernetes_permissions" "attach" {
  uid = data.alicloud_ram_users.default.users.0.id
  permissions {
    cluster     = data.alicloud_cs_managed_kubernetes_clusters.default.clusters.0.id
    role_type   = "namespace"
    role_name   = "cluster:admin"
    namespace   = "default"
    is_custom   = true
    is_ram_role = false
  }
  permissions {
    cluster     = data.alicloud_cs_managed_kubernetes_clusters.default.clusters.0.id
    role_type   = "namespace"
    role_name   = "edit"
    namespace   = "default"
    is_custom   = true
    is_ram_role = false
  }
}