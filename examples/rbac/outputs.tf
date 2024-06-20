output "network_watcher" {
  description = "This is the network watcher resource."
  value       = data.azurerm_network_watcher.this
}

output "resource_connection_monitor" {
  description = "This is the full output for the connection monitor resources."
  value       = module.network_watcher_rbac.resource_connection_monitor
}

output "resource_flow_log" {
  description = "This is the full output for the flow log resources."
  value       = module.network_watcher_rbac.resource_flow_log
}
