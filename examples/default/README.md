<!-- BEGIN_TF_DOCS -->
# Default example

Default deployment.  Includes example of assigning RBAC to a Network Watcher

```hcl
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.4.1"
}

resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags                = local.tags
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

data "azurerm_client_config" "current" {}

# This is the module call
# with a data source.
module "network_watcher_rbac" {
  source = "../../"

  location             = azurerm_resource_group.this.location
  network_watcher_id   = data.azurerm_network_watcher.this.id
  network_watcher_name = data.azurerm_network_watcher.this.name
  resource_group_name  = data.azurerm_network_watcher.this.resource_group_name
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry = var.enable_telemetry # see variables.tf
  role_assignments = {
    role_assignment = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Reader"
      description                = "Assign the Reader role to the deployment user on this network watcher."
    }
  }
  tags = local.tags

  depends_on = [data.azurerm_network_watcher.this]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (>= 0.11.2, < 1.0.0)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [time_sleep.wait_10_seconds_for_network_watcher_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_network_watcher.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_watcher) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_region"></a> [region](#input\_region)

Description: Azure region where the resource should be deployed.

Type: `string`

Default: `"polandcentral"`

## Outputs

The following outputs are exported:

### <a name="output_network_watcher"></a> [network\_watcher](#output\_network\_watcher)

Description: This is the network watcher resource.

### <a name="output_resource_connection_monitor"></a> [resource\_connection\_monitor](#output\_resource\_connection\_monitor)

Description: This is the full output for the connection monitor resources.

### <a name="output_resource_flow_log"></a> [resource\_flow\_log](#output\_resource\_flow\_log)

Description: This is the full output for the flow log resources.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.4.1

### <a name="module_network_watcher_rbac"></a> [network\_watcher\_rbac](#module\_network\_watcher\_rbac)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->