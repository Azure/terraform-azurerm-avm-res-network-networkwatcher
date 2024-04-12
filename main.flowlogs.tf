resource "azurerm_network_watcher_flow_log" "this" {
  enabled                   = var.flow_log.enabled
  name                      = var.flow_log.name
  network_security_group_id = var.flow_log.network_security_group_id
  network_watcher_name      = var.name
  resource_group_name       = var.resource_group_name
  storage_account_id        = var.flow_log.storage_account_id
  location                  = var.location
  tags                      = var.tags
  version                   = var.flow_log.version

  dynamic "retention_policy" {
    for_each = [var.flow_log.retention_policy]
    content {
      days    = retention_policy.value.days
      enabled = retention_policy.value.enabled
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
  dynamic "traffic_analytics" {
    for_each = var.flow_log.traffic_analytics == null ? [] : [var.flow_log.traffic_analytics]
    content {
      enabled               = var.flow_log.traffic_analytics.enabled
      workspace_id          = var.flow_log.traffic_analytics.workspace_id
      workspace_region      = var.flow_log.traffic_analytics.workspace_region
      workspace_resource_id = var.flow_log.traffic_analytics.workspace_resource_id
      interval_in_minutes   = var.flow_log.traffic_analytics.interval_in_minutes
    }
  }
}

