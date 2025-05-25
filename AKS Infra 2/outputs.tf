output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "kubernetes_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "client_certificate" {
  description = "The client certificate for the AKS cluster"
  value       = module.aks.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "The client key for the AKS cluster"
  value       = module.aks.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the AKS cluster"
  value       = module.aks.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "The host for the AKS cluster"
  value       = module.aks.host
  sensitive   = true
}

output "kube_config" {
  description = "The kube config for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL of the AKS cluster"
  value       = module.aks.oidc_issuer_url
}

output "acr_login_server" {
  description = "The login server for the Azure Container Registry"
  value       = module.acr.login_server
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.network.vnet_id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = module.network.aks_subnet_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace"
  value       = module.service_bus.namespace_name
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage.storage_account_name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "application_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}