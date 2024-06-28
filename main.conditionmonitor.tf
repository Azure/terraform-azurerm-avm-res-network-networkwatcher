resource "azurerm_network_connection_monitor" "this" {
  for_each = var.condition_monitor == null ? {} : tomap(var.condition_monitor)

  location                      = var.location
  name                          = each.value.name
  network_watcher_id            = var.network_watcher_id
  notes                         = each.value.notes
  output_workspace_resource_ids = each.value.output_workspace_resource_ids
  tags                          = var.tags

  dynamic "endpoint" {
    for_each = each.value.endpoint == null ? [] : each.value.endpoint
    content {
      name                  = endpoint.value.name
      address               = endpoint.value.address
      coverage_level        = endpoint.value.coverage_level
      excluded_ip_addresses = endpoint.value.excluded_ip_addresses
      included_ip_addresses = endpoint.value.included_ip_addresses
      target_resource_id    = endpoint.value.target_resource_id
      target_resource_type  = endpoint.value.target_resource_type

      dynamic "filter" {
        for_each = endpoint.value.filter == null ? [] : [endpoint.value.filter]
        content {
          type = filter.value.type

          dynamic "item" {
            for_each = filter.value.item == null ? [] : filter.value.item
            content {
              address = item.value.address
              type    = item.value.type
            }
          }
        }
      }
    }
  }
  dynamic "test_configuration" {
    for_each = each.value.test_configuration == null ? [] : each.value.test_configuration
    content {
      name                      = test_configuration.value.name
      protocol                  = test_configuration.value.protocol
      preferred_ip_version      = test_configuration.value.preferred_ip_version
      test_frequency_in_seconds = test_configuration.value.test_frequency_in_seconds

      dynamic "http_configuration" {
        for_each = test_configuration.value.http_configuration == null ? [] : [test_configuration.value.http_configuration]
        content {
          method                   = http_configuration.value.method
          path                     = http_configuration.value.path
          port                     = http_configuration.value.port
          prefer_https             = http_configuration.value.prefer_https
          valid_status_code_ranges = http_configuration.value.valid_status_code_ranges

          dynamic "request_header" {
            for_each = http_configuration.value.request_header == null ? [] : http_configuration.value.request_header
            content {
              name  = request_header.value.name
              value = request_header.value.value
            }
          }
        }
      }
      dynamic "icmp_configuration" {
        for_each = test_configuration.value.icmp_configuration == null ? [] : [test_configuration.value.icmp_configuration]
        content {
          trace_route_enabled = icmp_configuration.value.trace_route_enabled
        }
      }
      dynamic "success_threshold" {
        for_each = test_configuration.value.success_threshold == null ? [] : [test_configuration.value.success_threshold]
        content {
          checks_failed_percent = success_threshold.value.checks_failed_percent
          round_trip_time_ms    = success_threshold.value.round_trip_time_ms
        }
      }
      dynamic "tcp_configuration" {
        for_each = test_configuration.value.tcp_configuration == null ? [] : [test_configuration.value.tcp_configuration]
        content {
          port                      = tcp_configuration.value.port
          destination_port_behavior = tcp_configuration.value.destination_port_behavior
          trace_route_enabled       = tcp_configuration.value.trace_route_enabled
        }
      }
    }
  }
  dynamic "test_group" {
    for_each = each.value.test_group == null ? [] : each.value.test_group
    content {
      destination_endpoints    = test_group.value.destination_endpoints
      name                     = test_group.value.name
      source_endpoints         = test_group.value.source_endpoints
      test_configuration_names = test_group.value.test_configuration_names
      enabled                  = test_group.value.enabled
    }
  }
}

