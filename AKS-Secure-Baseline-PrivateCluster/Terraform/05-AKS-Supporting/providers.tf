terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  subscription_id = "3e336171-d512-41a4-8f0d-01790f9543e0"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
