<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13.1, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.107.0, < 4.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.6.2, < 4.0.0)

## Resources

The following resources are used by this module:

- [azapi_resource.flow_logs](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_network_connection_monitor.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_connection_monitor) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_network_watcher.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_watcher) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

### <a name="input_network_watcher_id"></a> [network\_watcher\_id](#input\_network\_watcher\_id)

Description: The ID of the Network Watcher.

Type: `string`

### <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name)

Description: The name of the Network Watcher.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the Network Watcher Resource Group.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_condition_monitor"></a> [condition\_monitor](#input\_condition\_monitor)

Description:   A map of condition monitors to create on the network watcher. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - (Required) The name which should be used for this Network Connection Monitor. Changing this forces a new resource to be created.
  - `location` - (Required) The Azure Region where the Network Connection Monitor should exist. Changing this forces a new resource to be created.
  - `endpoint` - (Required) Set of endpoint configuration for the condition monitor.
    - `address` - (Optional) The IP address or domain name of the Network Connection Monitor endpoint.
    - `coverage_level` - (Optional) The test coverage for the Network Connection Monitor endpoint. Possible values are `AboveAverage`, `Average`, `BelowAverage`, `Default`, `Full` and `Low`.
    - `excluded_ip_addresses` - (Optional) A list of IPv4/IPv6 subnet masks or IPv4/IPv6 IP addresses to be excluded to the Network Connection Monitor endpoint.
    - `included_ip_addresses` - (Optional) A list of IPv4/IPv6 subnet masks or IPv4/IPv6 IP addresses to be included to the Network Connection Monitor endpoint.
    - `name` - (Required) The name of the endpoint for the Network Connection Monitor .
    - `target_resource_id` - (Optional) The resource ID which is used as the endpoint by the Network Connection Monitor.
    - `target_resource_type` - (Optional) The endpoint type of the Network Connection Monitor. Possible values are `AzureArcVM`, `AzureSubnet`, `AzureVM`, `AzureVNet`, `ExternalAddress`, `MMAWorkspaceMachine` and `MMAWorkspaceNetwork`.
    - `filter` supports the following:
      - `type` - (Optional) The behaviour type of this endpoint filter. Currently the only allowed value is `Include`. Defaults to `Include`.
      - `item` supports the following:
        - `address` - (Optional) The address of the filter item.
        - `type` - (Optional) The type of items included in the filter. Possible values are `AgentAddress`. Defaults to `AgentAddress`.
  - `test_configuration` - (Required) Set of Test configuration for the condition monitor.
    - `name` - (Required) The name of test configuration for the Network Connection Monitor.
    - `preferred_ip_version` - (Optional) The preferred IP version which is used in the test evaluation. Possible values are `IPv4` and `IPv6`.
    - `protocol` - (Required) The protocol used to evaluate tests. Possible values are `Tcp`, `Http` and `Icmp`.
    - `test_frequency_in_seconds` - (Optional) The time interval in seconds at which the test evaluation will happen. Defaults to `60`.
    - `http_configuration` (Optional) A HTTP Configuration as
      - `method` - (Optional) The HTTP method for the HTTP request. Possible values are `Get` and `Post`. Defaults to `Get`.
      - `path` - (Optional) The path component of the URI. It only accepts the absolute path.
      - `port` - (Optional) The port for the HTTP connection.
      - `prefer_https` - (Optional) Should HTTPS be preferred over HTTP in cases where the choice is not explicit? Defaults to `false`.
      - `valid_status_code_ranges` - (Optional) The HTTP status codes to consider successful. For instance, `2xx`, `301-304` and `418`.
    - `request_header` supports the following:
      - `name` - (Required) The name of the HTTP header.
      - `value` - (Required) The value of the HTTP header.
    - `icmp_configuration` supports the following:
      - `trace_route_enabled` - (Optional) Should path evaluation with trace route be enabled? Defaults to `true`.
    - `success_threshold` supports the following:
      - `checks_failed_percent` - (Optional) The maximum percentage of failed checks permitted for a test to be successful.
      - `round_trip_time_ms` - (Optional) The maximum round-trip time in milliseconds permitted for a test to be successful.
    - `tcp_configuration` supports the following:
      - `destination_port_behavior` - (Optional) The destination port behavior for the TCP connection. Possible values are `None` and `ListenIfAvailable`.
      - `port` - (Required) The port for the TCP connection.
      - `trace_route_enabled` - (Optional) Should path evaluation with trace route be enabled? Defaults to `true`.
  - `test_group` - (Required) Set of test groups for the condition monitor.
    - `destination_endpoints` - (Required) A list of destination endpoint names.
    - `enabled` - (Optional) Should the test group be enabled? Defaults to `true`.
    - `name` - (Required) The name of the test group for the Network Connection Monitor.
    - `source_endpoints` - (Required) A list of source endpoint names.
    - `test_configuration_names` - (Required) A list of test configuration names.
  - `notes` - (Optional) The description of the Network Connection Monitor.
  - `output_workspace_resource_ids` - (Optional) A list of IDs of the Log Analytics Workspace which will accept the output from the Network Connection Monitor.

Type:

```hcl
map(object({
    name = string
    endpoint = set(object({
      address               = optional(string)
      coverage_level        = optional(string)
      excluded_ip_addresses = optional(set(string))
      included_ip_addresses = optional(set(string))
      name                  = string
      target_resource_id    = optional(string)
      target_resource_type  = optional(string)
      filter = optional(object({
        type = optional(string)
        item = optional(set(object({
          address = optional(string)
          type    = optional(string)
        })))
      }))
    }))
    test_configuration = set(object({
      name                      = string
      preferred_ip_version      = optional(string)
      protocol                  = string
      test_frequency_in_seconds = optional(number)
      http_configuration = optional(object({
        method                   = optional(string)
        path                     = optional(string)
        port                     = optional(number)
        prefer_https             = optional(bool)
        protocol                 = string
        valid_status_code_ranges = optional(set(string))
        request_header = optional(set(object({
          name  = string
          value = string
        })))
      }))
      icmp_configuration = optional(object({
        trace_route_enabled = optional(bool)
      }))
      success_threshold = optional(object({
        checks_failed_percent = optional(number)
        round_trip_time_ms    = optional(number)
      }))
      tcp_configuration = optional(object({
        destination_port_behavior = optional(string)
        port                      = number
        trace_route_enabled       = optional(bool)
      }))
    }))
    test_group = set(object({
      destination_endpoints    = set(string)
      enabled                  = optional(bool)
      name                     = string
      source_endpoints         = set(string)
      test_configuration_names = set(string)
    }))
    notes                         = optional(string, null)
    output_workspace_resource_ids = optional(list(string), null)
  }))
```

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_flow_logs"></a> [flow\_logs](#input\_flow\_logs)

Description:   
A map of role flow logs to create for the Network Watcher. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `enabled` - (Required) Should Network Flow Logging be Enabled?
- `name` - (Required) The name of the Network Watcher Flow Log. Changing this forces a new resource to be created.
- `target_resource_id` - (Required) The ID of the Network Security Group or Virtual Network for which to enable flow logs for. Changing this forces a new resource to be created.
- `network_watcher_name` - (Required) The name of the Network Watcher. Changing this forces a new resource to be created.
- `storage_account_id` - (Required) The ID of the Storage Account where flow logs are stored.
- `version` - (Optional) The version (revision) of the flow log. Possible values are `1` and `2`.
- `retention_policy` Supports the following:
  - `days` - (Required) The number of days to retain flow log records.
  - `enabled` - (Required) Boolean flag to enable/disable retention.
- `traffic_analytics` (Optional) Supports the following:
  - `enabled` - (Required) Boolean flag to enable/disable traffic analytics.
  - `interval_in_minutes` - (Optional) How frequently service should do flow analytics in minutes. Defaults to `60`.
  - `workspace_id` - (Required) The resource GUID of the attached workspace.
  - `workspace_region` - (Required) The location of the attached workspace.
  - `workspace_resource_id` - (Required) The resource ID of the attached workspace.

Type:

```hcl
map(object({
    enabled            = bool
    name               = string
    target_resource_id = string
    retention_policy = object({
      days    = number
      enabled = bool
    })
    storage_account_id = string
    traffic_analytics = optional(object({
      enabled               = bool
      interval_in_minutes   = optional(number)
      workspace_id          = string
      workspace_region      = string
      workspace_resource_id = string
      }), {
      enabled               = false
      interval_in_minutes   = 0
      workspace_id          = null
      workspace_region      = null
      workspace_resource_id = null
    })
    version = optional(number, null)
  }))
```

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The network watcher resource

### <a name="output_resource_connection_monitor"></a> [resource\_connection\_monitor](#output\_resource\_connection\_monitor)

Description: This is the full output for the connection monitor resources.

### <a name="output_resource_flow_log"></a> [resource\_flow\_log](#output\_resource\_flow\_log)

Description: This is the full output for the flow log resources.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id of the Network Watcher

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->