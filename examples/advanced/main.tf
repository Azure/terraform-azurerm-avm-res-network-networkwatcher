## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  min = 0
  max = length(module.regions.regions) - 1
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.1"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = module.regions.regions[random_integer.region_index.result].name
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "default" {
  source = "../../"
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry    = var.enable_telemetry # see variables.tf
  name                = module.naming.network_watcher.name_unique
  resource_group_name = azurerm_resource_group.this.name
  timeouts = {
    create = "31m",
    update = "31m",
    read   = "31m",
    delete = "31m"
  }
  lock = {
    name = "VMSSNoDelete"
    kind = "CanNotDelete"
  }
}
