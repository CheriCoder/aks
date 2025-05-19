terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "3e336171-d512-41a4-8f0d-01790f9543e0"
  features {}
}
