terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.20.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
  }
  required_version = ">= 1.5.0"

  backend "remote" {
    organization = "oorja_terraform"
    workspaces {
      name = "aks-infra"
    }
  }
}

provider "azurerm" {
  subscription_id = "3e336171-d512-41a4-8f0d-01790f9543e0"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "kubernetes" {
  config_path = "C:/Users/Oorja Saxena/.kube/config"
}
  /*
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "pwsh"  # Or "powershell"
    args = [
      "-Command", 
      "az aks get-credentials --resource-group oorja-dev-rg --name oorja-dev-aks --export"
    ]
  }
} */

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

data "azurerm_client_config" "current" {}