terraform {
  required_version = ">= 1.3.0"
  required_providers {
    # TODO: Ensure all required providers are listed here.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.97.1, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    azapi = {
      source = "azure/azapi"
      version = ">= 1.13.1, < 2.0.0"
    }
  }
}
