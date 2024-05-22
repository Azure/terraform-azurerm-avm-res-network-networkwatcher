resource "azapi_resource" "flow_logs" {
  for_each = var.flow_logs == null ? {} : tomap(var.flow_logs)
    type = "Microsoft.Network/networkWatchers/flowLogs@2023-11-01"
    name = each.value.name
    location = var.location
    parent_id = var.network_watcher_id
    tags = var.tags
    /*identity {
      type = "string"
      identity_ids = []
    }*/
    body = jsonencode({
      properties = {
        enabled = each.value.enabled
        flowAnalyticsConfiguration = {
          networkWatcherFlowAnalyticsConfiguration = {
            enabled = each.value.traffic_analytics.enabled
            trafficAnalyticsInterval = each.value.traffic_analytics.interval_in_minutes
            workspaceId = each.value.traffic_analytics.workspace_id
            workspaceRegion = each.value.traffic_analytics.workspace_region
            workspaceResourceId = each.value.traffic_analytics.workspace_resource_id
          }
        }
        format = {
          type = "JSON"
          version = each.value.version
        }
        retentionPolicy = {  
          days = each.value.retention_policy.days
          enabled = each.value.retention_policy.enabled
        }
        storageId = each.value.storage_account_id
        targetResourceId = each.value.target_resource_id
      }
    })
}