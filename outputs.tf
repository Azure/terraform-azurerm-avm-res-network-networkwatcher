# TODO: insert outputs here.

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource_flow_log" {
  value       = azapi_resource.flow_logs
  description = "This is the full output for the flow log resources."
}

