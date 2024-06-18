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

resource "azurerm_network_watcher" "this" {
  location            = var.region
  name                = module.naming.network_watcher.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

# This is the module call
# with a data source.
module "network_watcher_flow_log" {
  source = "../../"
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry     = var.enable_telemetry # see variables.tf
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  network_watcher_id   = azurerm_network_watcher.this.id
  network_watcher_name = azurerm_network_watcher.this.name
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
}
