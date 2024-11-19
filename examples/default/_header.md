# Flow Log example

This example deploys the module with an NSG Flow Log

## Deployed Services

- A network watcher.  
- A Key Vault
- A Log Analytics Workspace
- A virtual network, subnet and related NSG.    
- Two Virtual Machines, NIC, and related NSG.  Credentials are pulled from the VNet.
- A Network WAtcher Connection Monitor configured to monitor the communication from one VM to the other


## Well Architected Framework recommendations

- There are currently no Network Watcher Connection Monitor WAF recommendations.

## Other recommendations

Below are other recommendations related to Network Watcher representing good practices for deploying Network Watcher.

### Azure Cloud Adoption Framework

- Use [Connection Monitor to monitor Express Route connections](https://learn.microsoft.com/en-us/azure/expressroute/how-to-configure-connection-monitor).

