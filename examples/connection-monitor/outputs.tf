output "network_watcher" {
  description = "This is the network watcher resource."
  value       = azurerm_network_watcher.this
}

output "resource_connection_monitor" {
  description = "This is the full output for the connection monitor resources."
  value       = module.network_watcher_connection_monitor.resource_connection_monitor
}
