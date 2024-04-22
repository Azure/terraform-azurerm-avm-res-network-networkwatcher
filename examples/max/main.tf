# Change the default region if you already have a Network Watcher deployed to Central East.
# For simplicity code to find a random region is not included, as the random code can get complex.
variable "region" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = "polandcentral"
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
  tags = {
    source = "AVM Sample Default"
  }
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
  timeouts = {
    create = "32m",
    update = "32m",
    read   = "32m",
    delete = "32m"
  }
  role_assignments = {
    role_assignment = {
      principal_id               = azurerm_user_assigned_identity.this.principal_id
      role_definition_id_or_name = "Reader"
      description                = "Assign the Reader role to the deployment user on this virtual machine scale set resource scope."
    }
  }

  flow_logs = {
    subnet_flowlog = {
      enabled                   = true
      name                      = "fl-subnet" // not yet supported in the naming module
      network_security_group_id = azurerm_network_security_group.subnet.id
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
      timeouts = {
        create = "32m",
        update = "32m",
        read   = "32m",
        delete = "32m"
      }
    }
  }
  # Uncomment to add lock
  #lock = {
  #  name = "VMSSNoDelete"
  #  kind = "CanNotDelete"
  #}
  tags = local.tags
}
