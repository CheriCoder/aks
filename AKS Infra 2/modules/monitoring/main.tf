resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.prefix}-${var.environment}-law-monitoring"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_workspace" "this" {
  name                = "${var.prefix}-${var.environment}-amw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "container_insights" {
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

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "${var.prefix}-${var.environment}-aks-diag"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_application_insights" "this" {
  name                = "${var.prefix}-${var.environment}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.prefix}-${var.environment}-critical-ag"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.tags

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "node_cpu" {
  name                = "${var.prefix}-${var.environment}-node-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when CPU usage is high"
  severity            = 2
  window_size         = "PT5M"
  frequency           = "PT1M"
  
  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "node_memory" {
  name                = "${var.prefix}-${var.environment}-node-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when memory usage is high"
  severity            = 2
  window_size         = "PT5M"
  frequency           = "PT1M"
  
  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.tags
}

# Azure Monitor for Prometheus
/*
resource "azurerm_monitor_data_collection_rule" "aks_metrics" {
  count               = var.enable_prometheus ? 1 : 0
  name                = "${var.prefix}-${var.environment}-aks-metrics"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
      name                  = "aks-metrics"
    }
  }

  data_sources {
    prometheus_forwarder {
      name = "aks-prometheus"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  data_flow {
    destinations = ["aks-metrics"]
    streams      = ["Microsoft-PrometheusMetrics"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "aks_metrics" {
  count                   = var.enable_prometheus ? 1 : 0
  name                    = "${var.prefix}-${var.environment}-aks-metrics-association"
  target_resource_id      = var.aks_cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.aks_metrics[0].id
}
*/

# Azure Managed Grafana
resource "azurerm_dashboard_grafana" "this" {
  count               = var.enable_grafana ? 1 : 0
  name                = "${var.prefix}-${var.environment}-grafana"
  resource_group_name = var.resource_group_name
  location            = var.location
  grafana_major_version = 11
  
  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_monitor_workspace_integrations" {
    for_each = toset([azurerm_monitor_workspace.this.id])
    content {
      resource_id = azure_monitor_workspace_integrations.value
    }
  }

  tags = var.tags
}

# Grant permissions for Grafana to access Azure Monitor
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  count              = var.enable_grafana ? 1 : 0
  scope              = azurerm_monitor_workspace.this.id
  role_definition_name = "Monitoring Reader"
  principal_id       = azurerm_dashboard_grafana.this[0].identity[0].principal_id
  depends_on         = [azurerm_dashboard_grafana.this]
}

# Grant permissions for Grafana to access Log Analytics
resource "azurerm_role_assignment" "grafana_law_reader" {
  count              = var.enable_grafana ? 1 : 0
  scope              = azurerm_log_analytics_workspace.this.id
  role_definition_name = "Monitoring Reader"
  principal_id       = azurerm_dashboard_grafana.this[0].identity[0].principal_id
  depends_on         = [azurerm_dashboard_grafana.this]
}

# Enable Defender for Cloud
resource "azurerm_security_center_subscription_pricing" "kubernetes" {
  count         = var.enable_defender ? 1 : 0
  tier          = "Standard"
  resource_type = "KubernetesService"
}

resource "azurerm_security_center_setting" "mcas_integration" {
  count        = var.enable_defender ? 1 : 0
  setting_name = "MCAS"
  enabled      = true
}

# Loki, Tempo, and Mimir via Helm Charts (deployed to AKS)
resource "helm_release" "loki" {
  count      = var.enable_loki ? 1 : 0
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = "monitoring"
  create_namespace = true
  version    = "2.9.11"

  set {
    name  = "grafana.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.enabled"
    value = "false"
  }

  set {
    name  = "promtail.enabled"
    value = "true"
  }
}

resource "helm_release" "tempo" {
  count      = var.enable_tempo ? 1 : 0
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = "monitoring"
  create_namespace = true
  version    = "1.8.2"

  set {
    name  = "storage.trace.backend"
    value = "local"
  }
}

resource "helm_release" "mimir" {
  count      = var.enable_mimir ? 1 : 0
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = "monitoring"
  create_namespace = true
  version    = "5.1.0"
}