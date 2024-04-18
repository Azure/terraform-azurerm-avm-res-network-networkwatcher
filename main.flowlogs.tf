resource "azurerm_network_watcher_flow_log" "this" {
  for_each = var.flow_logs == null ? {} : tomap(var.flow_logs)
    enabled                   = each.value.enabled
    name                      = each.value.name
    network_security_group_id = each.value.network_security_group_id
    network_watcher_name      = var.name
    resource_group_name       = var.resource_group_name
    storage_account_id        = each.value.storage_account_id
    location                  = var.location
    tags                      = var.tags
    version                   = each.value.version

    dynamic "retention_policy" {
      for_each = [each.value.retention_policy]
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
      for_each = each.value.traffic_analytics == null ? [] : [each.value.traffic_analytics]
      content {
        enabled               = each.value.traffic_analytics.enabled
        workspace_id          = each.value.traffic_analytics.workspace_id
        workspace_region      = each.value.traffic_analytics.workspace_region
        workspace_resource_id = each.value.traffic_analytics.workspace_resource_id
        interval_in_minutes   = each.value.traffic_analytics.interval_in_minutes
      }
    }
}


