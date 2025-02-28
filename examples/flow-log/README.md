<!-- BEGIN_TF_DOCS -->
# Flow Log example

This example deploys the module with an NSG Flow Log

## Deployed Services

- A network watcher.  
- A virtual network and subnet.  The subnet is connected to the network watcher via a flow log.  The flow log has Traffic Analytics enabled.
- A virtual machine with a NIC and disk connected to a network security group.  The NIC network security group is connected to the network watcher via a flow log.  The flow log has Traffic Analytics enabled.

## Well Architected Framework recommendations

- [SE:06 Network Controls: Recommendations for networking and connectivity](https://learn.microsoft.com/en-us/azure/well-architected/security/networking).  Traffic Analytics: Monitor your network controls with Traffic Analytics. This is configured through Network Watcher, part of Azure Monitor, and aggregates inbound and outbound hits in your subnets collected by NSG.

## Other recommendations

Below are other recommendations related to Network Watcher representing good practices for deploying Network Watcher.

### Security Baseline for Azure

- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/network-watcher-security-baseline#im-1-use-centralized-identity-and-authentication-system)

### Azure Proactive Resiliency Library (APRL) for Network Watcher

APRL queries provide guidance on how to best deploy Network Watcher.  Run the APRL queries to see potential areas where you can improve your architecture.

- [Network Watcher APRL queries](https://azure.github.io/Azure-Proactive-Resiliency-Library/services/networking/network-watcher/).

### Best Practices

- [Enable NSG flow logs on critical subnets](https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-overview#best-practices).  This example implements this recommendation.

```hcl
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
  # source             = "Azure/azurerm-avm-res-network-networkwatcher/azurerm"
  enable_telemetry     = var.enable_telemetry # see variables.tf
  location             = azurerm_resource_group.this.location
  network_watcher_id   = data.azurerm_network_watcher.this.id
  network_watcher_name = data.azurerm_network_watcher.this.name
  resource_group_name  = data.azurerm_network_watcher.this.resource_group_name
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
  tags       = local.tags
  depends_on = [data.azurerm_network_watcher.this]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (>= 0.11.2, < 1.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_network_security_group.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_security_group.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet_network_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) (resource)
- [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
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

Default: `"norwayeast"`

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

### <a name="module_avm_res_keyvault_vault"></a> [avm\_res\_keyvault\_vault](#module\_avm\_res\_keyvault\_vault)

Source: Azure/avm-res-keyvault-vault/azurerm

Version: >= 0.6.0

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.4.1

### <a name="module_network_watcher_flow_log"></a> [network\_watcher\_flow\_log](#module\_network\_watcher\_flow\_log)

Source: ../../

Version:

### <a name="module_virtual_machine"></a> [virtual\_machine](#module\_virtual\_machine)

Source: Azure/avm-res-compute-virtualmachine/azurerm

Version: 0.18.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->