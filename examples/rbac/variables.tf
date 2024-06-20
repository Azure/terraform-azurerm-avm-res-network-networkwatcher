variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# Change the default region if you already have a Network Watcher deployed to Central East.
# For simplicity code to find a random region is not included, as the random code can get complex.
variable "region" {
  type        = string
  default     = "polandcentral"
  description = "Azure region where the resource should be deployed."
}
