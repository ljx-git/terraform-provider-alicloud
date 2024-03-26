output "user_name" {
  value = alicloud_ram_user.user.name
}

output "user_id" {
  value = alicloud_ram_user.user.id
}

output "cluster_name" {
  value = alicloud_cs_managed_kubernetes.default.name
}

output "cluster_id" {
  value = alicloud_cs_managed_kubernetes.default.id
}

output "permission_default" {
  value = alicloud_cs_kubernetes_permissions.default.permissions
}

output "permission_attach" {
  value = alicloud_cs_kubernetes_permissions.attach.permissions
}