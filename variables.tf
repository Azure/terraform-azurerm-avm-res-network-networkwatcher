variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
}

variable "name" {
  type        = string
  description = "The name of the this resource."
  validation {
    error_message = "The name can be up to 80 characters long. It must begin with a word character, and it must end with either a word character, a number or a '_'. The name may contain word characters or '.', '-', '_'."
    condition     = can(regex("^\\w[\\w.-]{0,78}[\\w_]$", var.name))
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
The timeouts block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
 - `create` - (Defaults to 30 minutes) Used when creating the Network Watcher.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Network Watcher.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Network Watcher.
 - `update` - (Defaults to 30 minutes) Used when updating the Network Watcher.
EOT
}

variable "flow_logs" {
  type = map(object({
    enabled                   = string
    name                      = string
    network_security_group_id = string
    retention_policy = object({
      days    = string
      enabled = string
    })
    storage_account_id = string
    traffic_analytics = object({
      enabled               = string
      interval_in_minutes   = optional(number)
      workspace_id          = string
      workspace_region      = string
      workspace_resource_id = string
    })
    version = optional(string, null)
    timeouts = object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    })
  }))
  default     = null
  description = <<-EOT

  A map of role flow logs to create for the Network Watcher. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
 - `enabled` - (Required) Should Network Flow Logging be Enabled?
 - `name` - (Required) The name of the Network Watcher Flow Log. Changing this forces a new resource to be created.
 - `network_security_group_id` - (Required) The ID of the Network Security Group for which to enable flow logs for. Changing this forces a new resource to be created.
 - `network_watcher_name` - (Required) The name of the Network Watcher. Changing this forces a new resource to be created.
 - `storage_account_id` - (Required) The ID of the Storage Account where flow logs are stored.
 - `version` - (Optional) The version (revision) of the flow log. Possible values are `1` and `2`.

---
 `retention_policy` block supports the following:
 - `days` - (Required) The number of days to retain flow log records.
 - `enabled` - (Required) Boolean flag to enable/disable retention.

---
 `traffic_analytics` block supports the following:
 - `enabled` - (Required) Boolean flag to enable/disable traffic analytics.
 - `interval_in_minutes` - (Optional) How frequently service should do flow analytics in minutes. Defaults to `60`.
 - `workspace_id` - (Required) The resource GUID of the attached workspace.
 - `workspace_region` - (Required) The location of the attached workspace.
 - `workspace_resource_id` - (Required) The resource ID of the attached workspace.

---
 `timeouts` block supports the following. The timeouts block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
 - `create` - (Defaults to 30 minutes) Used when creating the Network Watcher.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Network Watcher.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Network Watcher.
 - `update` - (Defaults to 30 minutes) Used when updating the Network Watcher.

EOT
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."
  default     = {}
  nullable    = false
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind)
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(any)
  description = "The map of tags to be applied to the resource"
  default     = {}
}

