resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  prefix             = var.prefix
  environment        = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space      = var.address_space
  subnet_prefixes    = var.subnet_prefixes
  tags               = var.tags
}

module "acr" {
  source = "./modules/acr"

  prefix             = var.prefix
  environment        = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                = var.acr_sku
  geo_replications   = var.acr_geo_replications
  enable_private_endpoint = var.enable_private_endpoints
  private_endpoint_subnet_id = module.network.private_subnet_id
  tags               = var.tags
}

module "firewall" {
  source = "./modules/firewall"
  count  = var.enable_firewall ? 1 : 0

  prefix               = var.prefix
  environment          = var.environment
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  vnet_name            = module.network.vnet_name
  firewall_subnet_cidr = var.firewall_subnet_cidr
  aks_subnet_cidr      = var.subnet_prefixes["aks"]
  tags                 = var.tags
}

module "key_vault" {
  source = "./modules/keyvault"

  prefix               = var.prefix
  environment          = var.environment
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  allowed_ips          = var.key_vault_allowed_ips
  enable_private_endpoint = var.enable_private_endpoints
  private_endpoint_subnet_id = module.network.private_subnet_id
  aks_subnet_id        = module.network.aks_subnet_id
  tags                 = var.tags
}

module "aks" {
  source = "./modules/aks"

  prefix                   = var.prefix
  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  kubernetes_version       = var.kubernetes_version
  node_count               = var.node_count
  vm_size                  = var.vm_size
  vnet_id                  = module.network.vnet_id
  vnet_subnet_id           = module.network.aks_subnet_id
  acr_id                   = module.acr.acr_id
  admin_username           = var.admin_username
  ssh_public_key           = var.ssh_public_key
  enable_auto_scaling      = var.enable_auto_scaling
  min_count                = var.min_count
  max_count                = var.max_count
  private_cluster_enabled  = var.private_cluster_enabled
  enable_pod_security_policy = var.enable_pod_security_policy
  enable_node_pools        = var.enable_node_pools
  node_pools               = var.node_pools
  enable_gpu               = var.enable_gpu
  gpu_node_count           = var.gpu_node_count
  gpu_min_count            = var.gpu_min_count
  gpu_max_count            = var.gpu_max_count
  key_vault_id             = module.key_vault.key_vault_id
  next_hop_ip              = var.enable_firewall ? module.firewall[0].firewall_private_ip : null
  tags                     = var.tags
  depends_on               = [module.network]
}

module "service_bus" {
  source = "./modules/servicebus"

  prefix             = var.prefix
  environment        = var.environment
  location           = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                = var.service_bus_sku
  capacity           = var.service_bus_capacity
  topics             = var.service_bus_topics
  queues             = var.service_bus_queues
  enable_private_endpoint = var.enable_private_endpoints
  private_endpoint_subnet_id = module.network.private_subnet_id
  tags               = var.tags
}

module "storage" {
  source = "./modules/storage"

  prefix                   = var.prefix
  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  storage_account_tier     = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  container_names          = var.storage_container_names
  file_share_names         = var.storage_file_share_names
  file_share_quota         = var.storage_file_share_quota
  allowed_ips              = var.storage_allowed_ips
  enable_private_endpoint  = var.enable_private_endpoints
  private_endpoint_subnet_id = module.network.private_subnet_id
  create_kubernetes_storage_class = true
  tags                     = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  prefix                   = var.prefix
  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  aks_cluster_id           = module.aks.cluster_id
  log_analytics_workspace_sku = var.log_analytics_workspace_sku
  retention_in_days        = var.log_retention_in_days
  alert_email              = var.alert_email
  enable_grafana           = var.enable_grafana
  enable_loki              = var.enable_loki
  enable_tempo             = var.enable_tempo
  enable_mimir             = var.enable_mimir
  enable_prometheus        = var.enable_prometheus
  enable_defender          = var.enable_defender
  vnet_id                  = module.network.vnet_id
  private_subnet_id        = module.network.private_subnet_id
  tags                     = var.tags
}