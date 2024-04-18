# Max example

This example deploys the module in its most complex form.  The deployment includes:
- A network watcher deployed with timeouts and a role assignment.  Commented code shows how to do a lock.
- A virtual network and subnet.  The subnet is connected to the network watcher via a flow log.  The flow log has Traffic Analytics enabled.
