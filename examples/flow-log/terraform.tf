terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.1, < 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.107.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
}