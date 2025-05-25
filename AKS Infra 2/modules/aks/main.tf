data "azurerm_client_config" "current" {}
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.prefix}-${var.environment}-aks-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "aks_key_vault" {
  scope                = var.key_vault_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "random_string" "dns_prefix" {
  length  = 8
  special = false
  upper   = false
}
/* Use system private DNS zone as I don't have permissions to create private DNS zones
resource "azurerm_private_dns_zone" "aks" {
  count               = var.private_cluster_enabled ? 1 : 0
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  count                 = var.private_cluster_enabled ? 1 : 0
  name                  = "${var.prefix}-${var.environment}-aks-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks[0].name
  virtual_network_id    = var.vnet_id
}
*/
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.prefix}-${var.environment}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-${var.environment}-${random_string.dns_prefix.result}"
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = "System" # Use system private DNS zone as I don't have permissions to create private DNS zones
  #private_dns_zone_id     = var.private_cluster_enabled ? azurerm_private_dns_zone.aks[0].id : null
  oidc_issuer_enabled     = true
  workload_identity_enabled = true

  default_node_pool {
    name                = "system"
    node_count          = var.enable_auto_scaling ? null : var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    auto_scaling_enabled = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    os_disk_size_gb     = 50
    type                = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    # enable_host_encryption = true
    max_pods              = 110
    ultra_ssd_enabled     = false
    upgrade_settings {
      max_surge = "33%"
    }
    tags = var.tags
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aks.id
    ]
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    network_plugin_mode = "overlay"  
    pod_cidr           = "10.244.0.0/16" 
  }

  azure_policy_enabled = true
  
  azure_active_directory_role_based_access_control {
    # managed = true
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = length(var.aad_admin_group_ids) > 0 ? var.aad_admin_group_ids : null
  }

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [0, 1, 2, 3, 4]
    }
  }

  # automatic_channel_upgrade = "stable"

  oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

microsoft_defender {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

  depends_on = [
    azurerm_role_assignment.aks_network,
    azurerm_role_assignment.aks_acr,
    azurerm_role_assignment.aks_key_vault
  ]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version
    ]
  }
}

# Create additional node pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each              = var.enable_node_pools ? var.node_pools : {}
  
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count
  auto_scaling_enabled  = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  vnet_subnet_id        = var.vnet_subnet_id
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_type               = each.value.os_type
  priority              = each.value.priority
  eviction_policy       = each.value.eviction_policy
  
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  
  max_pods              = 110
  
  tags = var.tags
}

# GPU Node Pool remains commented out as in your original file
/*
resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  count                 = var.enable_gpu ? 1 : 0
  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_NC6s_v3"  # GPU VM size
  node_count            = var.gpu_node_count
  enable_auto_scaling   = true
  min_count             = var.gpu_min_count
  max_count             = var.gpu_max_count
  vnet_subnet_id        = var.vnet_subnet_id
  os_disk_size_gb       = 128
  
  node_labels = {
    "accelerator" = "nvidia"
    "nodepool-type" = "gpu"
  }
  
  node_taints = [
    "nvidia.com/gpu=present:NoSchedule"
  ]
  
  tags = var.tags
} 
*/

# Create route for egress traffic
resource "azurerm_route" "internet_via_fw" {
  count               = var.next_hop_ip != null ? 1 : 0
  name                = "internet-via-firewall"
  resource_group_name = var.resource_group_name
  route_table_name    = "aks-route-table" # Replace with var.route_table_name if available
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.next_hop_ip
}
/* Not availabe in East US region
# Pod Identity Extension (preview)
resource "azurerm_kubernetes_cluster_extension" "pod_identity" {
  name           = "pod-identity"
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = "Microsoft.Azure.PodIdentity"
}

# User assigned identity for pod identity
resource "azurerm_user_assigned_identity" "pod_identity" {
  name                = "${var.prefix}-${var.environment}-pod-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role assignment for pod identity
resource "azurerm_role_assignment" "pod_identity_operator" {
  scope                = azurerm_user_assigned_identity.pod_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# Workload Identity Extension
resource "azurerm_kubernetes_cluster_extension" "workload_identity" {
  name           = "workload-identity"
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = "Microsoft.WorkloadIdentity"
}
*/
# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.prefix}-${var.environment}-law-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "this" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}