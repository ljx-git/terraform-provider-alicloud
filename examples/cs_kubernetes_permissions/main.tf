data "alicloud_enhanced_nat_available_zones" "enhanced" {}

data "alicloud_cs_kubernetes_version" "default" {
  cluster_type       = "ManagedKubernetes"
}

resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

# According to the vswitch cidr blocks to launch several vswitches
resource "alicloud_vswitch" "default" {
  count      = length(var.vswitch_cidrs)
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = element(var.vswitch_cidrs, count.index)
  zone_id    = data.alicloud_enhanced_nat_available_zones.enhanced.zones[count.index].zone_id
}

# Create a new RAM cluster.
resource "alicloud_cs_managed_kubernetes" "default" {
  name                 = var.name
  cluster_spec         = "ack.pro.small"
  version              = data.alicloud_cs_kubernetes_version.default.metadata.0.version
  worker_vswitch_ids   = split(",", join(",", alicloud_vswitch.default.*.id))
  new_nat_gateway      = false
  pod_cidr             = var.pod_cidr
  service_cidr         = var.service_cidr
	slb_internet_enabled = false
}

# Create a new RAM user.
resource "alicloud_ram_user" "user" {
  name         = var.name
}

# Create a cluster permission for user.
resource "alicloud_cs_kubernetes_permissions" "default" {
  uid = alicloud_ram_user.user.id
  permissions {
    cluster     = alicloud_cs_managed_kubernetes.default.id
    role_type   = "cluster"
    role_name   = "admin"
    namespace   = ""
    is_custom   = false
    is_ram_role = false
  }
}

resource "alicloud_cs_kubernetes_permissions" "attach" {
  uid = alicloud_ram_user.user.id
  permissions {
    cluster     = alicloud_cs_managed_kubernetes.default.id
    role_type   = "namespace"
    role_name   = "cs:dev"
    namespace   = "default"
    is_custom   = true
    is_ram_role = false
  }
}