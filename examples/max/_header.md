# Max example

This example deploys the module in its most complex form.  The deployment includes:
- A network watcher deployed with timeouts and a role assignment.  Commented code shows how to do a lock.
- A virtual network and subnet.  The subnet is connected to the network watcher via a flow log.  The flow log has Traffic Analytics enabled.
- A virtual machine with a NIC and disk connected to a network security group.  The NIC network security group is connected to the network watcher via a flow log.  The flow log has Traffic Analytics enabled.

Well Architected Framework recommendations:
- [SE:06 Network Controls: Recommendations for networking and connectivity](https://learn.microsoft.com/en-us/azure/well-architected/security/networking).  Traffic Analytics: Monitor your network controls with Traffic Analytics. This is configured through Network Watcher, part of Azure Monitor, and aggregates inbound and outbound hits in your subnets collected by NSG.

