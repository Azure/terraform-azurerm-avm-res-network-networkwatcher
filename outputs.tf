output "resource" {
  description = "The network watcher resource"
  value       = data.azurerm_network_watcher.this
}

output "resource_connection_monitor" {
  description = "This is the full output for the connection monitor resources."
  value       = azurerm_network_connection_monitor.this[*]
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource_flow_log" {
  description = "This is the full output for the flow log resources."
  value       = azapi_resource.flow_logs
}

output "resource_group_name" {
  description = "The resource group name of the Network Watcher"
  value       = var.network_watcher_resource_group_name
}

output "resource_id" {
  description = "The resource id of the Network Watcher"
  value       = var.network_watcher_id
}
