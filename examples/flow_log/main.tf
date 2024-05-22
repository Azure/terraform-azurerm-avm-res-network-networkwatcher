# Change the default region if you already have a Network Watcher deployed to Central East.
# For simplicity code to find a random region is not included, as the random code can get complex.
variable "region" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = "norwayeast"
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.1"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = var.region
  tags = local.tags
}

resource "azurerm_network_watcher" "this" {
  location            = var.region
  name                = module.naming.network_watcher.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags = local.tags
}


# This is the module call
# with a data source.
module "default" {
  source = "../../"
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry    = var.enable_telemetry # see variables.tf
  name                = module.naming.network_watcher.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  network_watcher_id = azurerm_network_watcher.this.id
  flow_logs = {
    subnet_flowlog = {
      enabled                   = true
      name                      = "fl-subnet" # not yet supported in the naming module
      target_resource_id = azurerm_network_security_group.subnet.id
      storage_account_id        = azurerm_storage_account.this.id
      version                   = 2
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
      enabled                   = true
      name                      = "fl-nic" # not yet supported in the naming module
      target_resource_id = azurerm_network_security_group.nic.id
      storage_account_id        = azurerm_storage_account.this.id
      version                   = 2
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
      enabled                   = true
      name                      = "fl-vnet" # not yet supported in the naming module
      target_resource_id = azurerm_virtual_network.this.id
      storage_account_id        = azurerm_storage_account.this.id
      version                   = 2
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
