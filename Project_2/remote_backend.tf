terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.70.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  #   subscription_id = ""
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}