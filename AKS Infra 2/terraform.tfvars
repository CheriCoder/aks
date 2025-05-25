# General
prefix      = "oorja"
environment = "dev"
location    = "eastus"
tags = {
  Environment = "Development"
  Project     = "Oorja Platform"
  Owner       = "DevOps"
  ManagedBy   = "Terraform"
}

# Network
address_space = ["10.0.0.0/16"]
subnet_prefixes = {
  aks     = "10.0.1.0/24"
  private = "10.0.2.0/24"
}
firewall_subnet_cidr = "10.0.3.0/26"

# AKS
kubernetes_version     = "1.30.12"
node_count             = 2
vm_size                = "Standard_D2s_v3"
admin_username         = "azureadmin"
ssh_public_key         = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDg7XeZzLrasrn7v5fz8yGpi0/JrJAdsOWb6maCwYRJ6czEncGjy0+UbhRRO0h7m+R6FZ1ZRGIHG62Zqnkn06y/ayJ93c7zekdDTdpAnISm9lJRjp3MeDQOSHI/s+HiNl9kFZI3PHNC7A7TB+3PAiBh1DX4jf1+Zg9H32N0spkvyEl5ah1eRzVCygx5JEO+a/KNLxBToJkxE7nlq9Z055lNqhB6yQ9xOcNcsRI9bRnPENFwz4C79OdqBFHRgGk0kFsq+yxdy7jXd1AtcSzsU2zX5smOxUdjsVp9GoyrisXskCihS8eGqVrd/H8Iog/ndn4PJxUdSy3o7kpqvgD/Xk/PzO+vS8pFyOinLljXCbrkMUj336g0qXnN1vPkqFHTRvrJ9FtW2/b1fTMdpvWE5Xxc31oRPpUqygM6atd1JLvc65CBw30cuW4JZ+3HqCVrdCiBiIGhIhjuoSBeEZN+VP3AREZZoLVTJxhQZwUi0foponoNwsVkjMiCUlJ/+FNBxNoGBcxnk4SGxn2LXhrsQzf4CWvNfYauyMPsQP7GnNuuFLlut3/ULY9jR6mvNskMkP5e8mI8B5A8QzeOmFI7u5pgqZJ1NcsbRs8kESo/fTpiOJe1J+oTA5W1qejwK304FJElwXDsJ/wfQeNPbzMEgOlol5mh+13NaJMmlyvLdIH1Bw== saxenaoorja@gmail.com"
enable_auto_scaling    = true
min_count              = 1
max_count              = 5
private_cluster_enabled = true
enable_pod_security_policy = true

# Node Pools
enable_node_pools = true
node_pools = {
  "user" = {
    vm_size             = "Standard_D4s_v3"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    node_labels         = { "nodepool-type" = "user", "environment" = "dev" }
    node_taints         = []
    os_disk_size_gb     = 100
    os_type             = "Linux"
    priority            = "Regular"
    eviction_policy     = null
  },
  "apps" = {
    vm_size             = "Standard_D2s_v3"
    node_count          = 2
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    node_labels         = { "nodepool-type" = "apps", "environment" = "dev" }
    node_taints         = []
    os_disk_size_gb     = 50
    os_type             = "Linux"
    priority            = "Regular"
    eviction_policy     = null
  }
}

# GPU (disabled in dev)
enable_gpu     = false
gpu_node_count = 0
gpu_min_count  = 0
gpu_max_count  = 0

# ACR
acr_sku = "Premium"
acr_geo_replications = []

# Key Vault
key_vault_allowed_ips = ["0.0.0.0/0"]  # You should replace this with your corporate IPs or VPN

# Service Bus
service_bus_sku = "Standard"
service_bus_capacity = 0
service_bus_topics = {
  "events" = ["subscription1", "subscription2"]
  "notifications" = ["email", "sms", "push"]
}
service_bus_queues = ["jobs", "deadletter"]

# Storage
storage_account_tier = "Standard"
storage_account_replication_type = "LRS"
storage_container_names = ["data", "backups", "artifacts", "uploads"]
storage_file_share_names = ["config", "persistent"]
storage_file_share_quota = 50
storage_allowed_ips = []  # You should replace this with your corporate IPs or VPN

# Monitoring
log_analytics_workspace_sku = "PerGB2018"
log_retention_in_days = 30
alert_email = "oorja.saxena@harman.com"  
enable_grafana = false 
enable_loki = false
enable_tempo = false
enable_mimir = false
enable_prometheus = false #(not available in free tier)
enable_defender = false  # Typically disabled in dev to save costs

# Network Security
enable_firewall = false  # Typically disabled in dev to save costs
#enable_private_endpoints = true (not available in free tier)