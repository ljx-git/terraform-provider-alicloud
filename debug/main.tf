variable "name_regex" {
  default = "test"
}

# Declare the data source
data "alicloud_ram_users" "default" {
  name_regex = var.name_regex
}

# permissions
data "alicloud_cs_kubernetes_permissions" "default" {
  uid = data.alicloud_ram_users.default.users.0.id
}

output "permissions" {
  value = data.alicloud_cs_kubernetes_permissions.default.permissions
}