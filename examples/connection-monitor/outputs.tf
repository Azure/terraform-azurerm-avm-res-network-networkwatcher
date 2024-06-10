output "resource_connection_monitor" {
  value       = module.network_watcher_connection_monitor.resource_connection_monitor
  description = "This is the full output for the connection monitor resources."
}

output "network_watcher" {
  value       = azurerm_network_watcher.this
  description = "This is the network watcher resource."
}
