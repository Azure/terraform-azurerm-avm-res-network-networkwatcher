locals {
  network_watcher_name                = "NetworkWatcher_${var.region}"
  network_watcher_resource_group_name = "NetworkWatcherRG"
  tags = {
    scenario = "Network Watcher Flow Logs AVM Sample"
  }
}