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