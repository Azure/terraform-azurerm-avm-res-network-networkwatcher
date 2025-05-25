# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.1"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.region
  name     = module.naming.resource_group.name_unique
  tags     = local.tags
}

# Wait 10 seconds for the network watcher to be created as a byproduct of the VNet creation
resource "time_sleep" "wait_10_seconds_for_network_watcher_creation" {
  create_duration = "10s"

  depends_on = [azurerm_virtual_network.this]
}

data "azurerm_network_watcher" "this" {
  name                = local.network_watcher_name
  resource_group_name = local.network_watcher_resource_group_name

  depends_on = [time_sleep.wait_10_seconds_for_network_watcher_creation]
}

# This is the module call
# with a data source.
module "network_watcher_flow_log" {
  source = "../../"

  location             = azurerm_resource_group.this.location
  network_watcher_id   = data.azurerm_network_watcher.this.id
  network_watcher_name = data.azurerm_network_watcher.this.name
  resource_group_name  = data.azurerm_network_watcher.this.resource_group_name
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry = var.enable_telemetry # see variables.tf
  flow_logs = {
    subnet_flowlog = {
      enabled            = true
      name               = "fl-subnet" # not yet supported in the naming module
      target_resource_id = azurerm_network_security_group.subnet.id
      storage_account_id = azurerm_storage_account.this.id
      version            = 2
      retention_policy = {
        days    = 30
        enabled = true
      }
      traffic_analytics = {
        enabled               = true
        workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
        workspace_region      = var.region
        workspace_resource_id = azurerm_log_analytics_workspace.this.id
        interval_in_minutes   = 10
      }
    }
    nic_flowlog = {
      enabled            = true
      name               = "fl-nic" # not yet supported in the naming module
      target_resource_id = azurerm_network_security_group.nic.id
      storage_account_id = azurerm_storage_account.this.id
      version            = 2
      retention_policy = {
        days    = 30
        enabled = true
      }
      traffic_analytics = {
        enabled               = true
        workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
        workspace_region      = var.region
        workspace_resource_id = azurerm_log_analytics_workspace.this.id
        interval_in_minutes   = 10
      }
    }
    vnet_flowlog = {
      enabled            = true
      name               = "fl-vnet" # not yet supported in the naming module
      target_resource_id = azurerm_virtual_network.this.id
      storage_account_id = azurerm_storage_account.this.id
      version            = 2
      retention_policy = {
        days    = 30
        enabled = true
      }
      traffic_analytics = {
        enabled               = true
        workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
        workspace_region      = var.region
        workspace_resource_id = azurerm_log_analytics_workspace.this.id
        interval_in_minutes   = 10
      }
    }
  }
  tags = local.tags

  depends_on = [data.azurerm_network_watcher.this]
}
