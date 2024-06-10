# Change the default region if you already have a Network Watcher deployed to Central East.
# For simplicity code to find a random region is not included, as the random code can get complex.
variable "region" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = "swedencentral"
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

data "azurerm_client_config" "current" {}

# This is the module call
# with a data source.
module "default" {
  source = "../../"
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry    = var.enable_telemetry # see variables.tf
  name                = azurerm_network_watcher.this.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  network_watcher_id  = azurerm_network_watcher.this.id
  tags = local.tags
  role_assignments = {
    role_assignment = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Reader"
      description                = "Assign the Reader role to the deployment user on this network watcher."
    }
  }
}