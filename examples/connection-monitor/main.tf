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

module "network_watcher_connection_monitor" {
  source = "../../"
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry     = var.enable_telemetry # see variables.tf
  location             = azurerm_resource_group.this.location
  network_watcher_id   = data.azurerm_network_watcher.this.id
  network_watcher_name = data.azurerm_network_watcher.this.name
  resource_group_name  = data.azurerm_network_watcher.this.resource_group_name
  tags                 = local.tags

  condition_monitor = {
    monitor = {
      name = "test-connection-monitor"
      endpoint = [
        {
          name               = "endpoint-vm1"
          target_resource_id = module.virtual_machine_1.resource_id
        },
        {
          name               = "endpoint-vm2"
          target_resource_id = module.virtual_machine_2.resource_id
        }
      ]
      test_group = [
        {
          name                  = "test-group"
          enabled               = true
          source_endpoints      = ["endpoint-vm1"]
          destination_endpoints = ["endpoint-vm2"]
        }
      ]
      test_configuration = [
        {
          name                      = "test-config"
          test_frequency_in_seconds = 60
          protocol                  = "Tcp"
          tcp_configuration = {
            port = 80
          }
        }
      ]
      test_group = [
        {
          name                     = "test-group"
          source_endpoints         = ["endpoint-vm1"]
          destination_endpoints    = ["endpoint-vm2"]
          test_configuration_names = ["test-config"]
        }
      ]
      notes = "This is a test connection monitor"
      output_workspace_resource_ids = [
        azurerm_log_analytics_workspace.this.id
      ]
    }
  }

  # Wait 60 seconds for the virtual machine extensions to be active
  depends_on = [time_sleep.wait_60_seconds_for_virtual_machine_extensions_to_be_active, data.azurerm_network_watcher.this]
}
