resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    source = "AVM Sample Default Deployment"
  }
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# network security group for the subnet with a rule to allow http, https and ssh traffic
resource "azurerm_network_security_group" "subnet" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "allow-http"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "allow-https"
    priority                   = 101
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  #ssh security rule
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "allow-ssh"
    priority                   = 102
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

# network security group for the nic with a rule to allow http, https and ssh traffic
resource "azurerm_network_security_group" "vm" {
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.network_security_group.name_unique}-001"
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "allow-http"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "allow-https"
    priority                   = 101
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
  #ssh security rule
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "allow-ssh"
    priority                   = 102
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  network_security_group_id = azurerm_network_security_group.subnet.id
  subnet_id                 = azurerm_subnet.subnet.id
}

data "azurerm_client_config" "current" {}

module "avm_res_keyvault_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = ">= 0.6.0"

  location            = azurerm_resource_group.this.location
  name                = module.naming.key_vault.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  network_acls = {
    default_action = "Allow"
  }
  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  tags = {
    source = "AVM Sample Default Deployment"
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}

module "virtual_machine_1" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.18.0"

  location = azurerm_resource_group.this.location
  name     = module.naming.virtual_machine.name_unique
  network_interfaces = {
    network_interface_1 = {
      name                      = module.naming.network_interface.name_unique
      network_security_group_id = azurerm_network_security_group.vm.id
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.subnet.id
        }
      }
    }
  }
  resource_group_name = azurerm_resource_group.this.name
  zone                = 2
  enable_telemetry    = var.enable_telemetry
  extensions = {
    network_watcher = {
      name                       = "networkWatcher"
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = "NetworkWatcherAgentLinux"
      type_handler_version       = "1.4"
      auto_upgrade_minor_version = true
    }
  }
  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  }
  os_type  = "Linux"
  sku_size = "Standard_DS2_v2"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [
    module.avm_res_keyvault_vault
  ]
}

module "virtual_machine_2" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.18.0"

  location = azurerm_resource_group.this.location
  name     = "${module.naming.virtual_machine.name_unique}-002"
  network_interfaces = {
    network_interface_1 = {
      name                      = "${module.naming.network_interface.name_unique}-002"
      network_security_group_id = azurerm_network_security_group.vm.id
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.subnet.id
        }
      }
    }
  }
  resource_group_name = azurerm_resource_group.this.name
  zone                = 2
  enable_telemetry    = var.enable_telemetry
  extensions = {
    network_watcher = {
      name                       = "networkWatcher"
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = "NetworkWatcherAgentLinux"
      type_handler_version       = "1.4"
      auto_upgrade_minor_version = true
    }
  }
  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  }
  os_type  = "Linux"
  sku_size = "Standard_DS2_v2"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [
    module.avm_res_keyvault_vault
  ]
}

# Wait 60 seconds for the virtual machine extensions to be active
resource "time_sleep" "wait_60_seconds_for_virtual_machine_extensions_to_be_active" {
  create_duration = "60s"

  depends_on = [module.virtual_machine_1, module.virtual_machine_2]
}


resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}
