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

resource "azurerm_network_watcher" "this" {
  location            = var.region
  name                = module.naming.network_watcher.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
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
  network_watcher_id  = azurerm_network_watcher.this.id
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13.1, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.107.0, < 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.6.2, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.107.0, < 4.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_network_security_group.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_security_group.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_watcher.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet_network_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) (resource)
- [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

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

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_res_keyvault_vault"></a> [avm\_res\_keyvault\_vault](#module\_avm\_res\_keyvault\_vault)

Source: Azure/avm-res-keyvault-vault/azurerm

Version: >= 0.6.0

### <a name="module_default"></a> [default](#module\_default)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.4.1

### <a name="module_virtual_machine"></a> [virtual\_machine](#module\_virtual\_machine)

Source: Azure/avm-res-compute-virtualmachine/azurerm

Version: 0.14.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->