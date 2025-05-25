# General
variable "prefix" {
  description = "The prefix for all resources"
  type        = string
  default     = "aks"
}

variable "environment" {
  description = "The environment (dev, test, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Network
variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "The address prefixes for the subnets"
  type        = map(string)
  default     = {
    aks     = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

variable "firewall_subnet_cidr" {
  description = "The CIDR for the Azure Firewall subnet"
  type        = string
  default     = "10.0.3.0/26"  # Must be at least /26
}

# AKS
variable "kubernetes_version" {
  description = "The Kubernetes version"
  type        = string
  default     = "1.27.3"
}

variable "node_count" {
  description = "The initial number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "The admin username for the Linux VMs"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "The SSH public key for the Linux VMs"
  type        = string
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the AKS cluster"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "The minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "The maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

variable "private_cluster_enabled" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy for AKS"
  type        = bool
  default     = true
}

variable "enable_node_pools" {
  description = "Enable additional node pools"
  type        = bool
  default     = true
}

variable "node_pools" {
  description = "Map of node pool configurations"
  type        = map(object({
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_labels         = map(string)
    node_taints         = list(string)
    os_disk_size_gb     = number
    os_type             = string
    priority            = string
    eviction_policy     = string
  }))
  default     = {
    "user" = {
      vm_size             = "Standard_D2s_v3"
      node_count          = 2
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      node_labels         = { "nodepool-type" = "user" }
      node_taints         = []
      os_disk_size_gb     = 50
      os_type             = "Linux"
      priority            = "Regular"
      eviction_policy     = null
    }
  }
}

variable "enable_gpu" {
  description = "Enable GPU node pool"
  type        = bool
  default     = false
}

variable "gpu_node_count" {
  description = "The number of GPU nodes"
  type        = number
  default     = 1
}

variable "gpu_min_count" {
  description = "The minimum number of GPU nodes for auto-scaling"
  type        = number
  default     = 0
}

variable "gpu_max_count" {
  description = "The maximum number of GPU nodes for auto-scaling"
  type        = number
  default     = 3
}

# ACR
variable "acr_sku" {
  description = "The SKU for the Azure Container Registry"
  type        = string
  default     = "Premium"
}

variable "acr_geo_replications" {
  description = "Locations for ACR geo-replication"
  type        = list(string)
  default     = []
}

# Key Vault
variable "key_vault_allowed_ips" {
  description = "List of allowed IP addresses for the Key Vault"
  type        = list(string)
  default     = []
}

# Service Bus
variable "service_bus_sku" {
  description = "The SKU of the Service Bus Namespace"
  type        = string
  default     = "Standard"
}

variable "service_bus_capacity" {
  description = "The capacity of the Service Bus Namespace"
  type        = number
  default     = 0
}

variable "service_bus_topics" {
  description = "Map of Service Bus topics and subscriptions"
  type        = map(list(string))
  default     = {
    "events" = ["subscription1", "subscription2"]
  }
}

variable "service_bus_queues" {
  description = "List of Service Bus queue names"
  type        = list(string)
  default     = ["queue1", "queue2"]
}

# Storage
variable "storage_account_tier" {
  description = "The tier for the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
  default     = "LRS"
}

variable "storage_container_names" {
  description = "The names of the containers to create"
  type        = list(string)
  default     = ["data", "backups", "artifacts"]
}

variable "storage_file_share_names" {
  description = "The names of the file shares to create"
  type        = list(string)
  default     = ["config", "persistent"]
}

variable "storage_file_share_quota" {
  description = "The quota in GB for the file shares"
  type        = number
  default     = 50
}

variable "storage_allowed_ips" {
  description = "List of allowed IP addresses for the storage account"
  type        = list(string)
  default     = []
}

# Monitoring
variable "log_analytics_workspace_sku" {
  description = "The SKU for the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for logs in days"
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "admin@example.com"
}

variable "enable_grafana" {
  description = "Enable Azure Managed Grafana"
  type        = bool
  default     = true
}

variable "enable_loki" {
  description = "Enable Loki for log aggregation"
  type        = bool
  default     = true
}

variable "enable_tempo" {
  description = "Enable Tempo for distributed tracing"
  type        = bool
  default     = true
}

variable "enable_mimir" {
  description = "Enable Mimir for metrics"
  type        = bool
  default     = true
}

variable "enable_prometheus" {
  description = "Enable Azure Monitor managed Prometheus"
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud"
  type        = bool
  default     = true
}

# Network Security
variable "enable_firewall" {
  description = "Enable Azure Firewall"
  type        = bool
  default     = true
}

variable "enable_private_endpoints" {
  description = "Enable Private Endpoints for PaaS services"
  type        = bool
  default     = true
}