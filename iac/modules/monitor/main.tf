
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  name               = "vm-diagnostics"
  target_resource_id = var.vm_id
  logs {
    category = "VMGuest"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metrics {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  workspace_id = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_monitor_smart_detection_alert" "alert" {
  name                           = "cpu-high-alert"
  resource_group_name            = var.resource_group_name
  scope                          = var.vm_id
  enabled                        = true
  severity                       = "Sev3"
  target_resource_id            = var.vm_id
  alert_rule {
    metric_name                = "Percentage CPU"
    operator                   = "GreaterThan"
    threshold                  = 90
    time_aggregation           = "Average"
    period                     = "PT5M"
    evaluation_frequency       = "PT5M"
    window_size                = "PT5M"
  }
}

resource "azurerm_dashboard" "vm_dashboard" {
  name               = "vm-monitoring-dashboard"
  resource_group_name = var.resource_group_name
  location           = var.location
  display_name       = "VM Monitoring Dashboard"

  widget {
    type = "MetricChart"
    name = "CPU Usage"
    metrics {
      resource_id   = var.vm_id
      metric_name   = "Percentage CPU"
      aggregation   = "Average"
      time_grain    = "PT1M"
    }
  }

  widget {
    type = "MetricChart"
    name = "Disk Usage"
    metrics {
      resource_id   = var.vm_id
      metric_name   = "Disk Read Bytes"
      aggregation   = "Average"
      time_grain    = "PT1M"
    }
  }
}
    