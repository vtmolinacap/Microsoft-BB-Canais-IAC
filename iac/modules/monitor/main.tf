resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  name                       = "diag-${var.environment}-eastus"
  target_resource_id         = var.virtual_machine_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "LinuxSyslog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "LinuxSyslogEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "ag-${var.environment}-eastus"
  short_name          = "ag-${var.environment}"
  resource_group_name = var.resource_group_name

  email_receiver {
    name                    = "admin_notification"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "alert" {
  name                = "alert-${var.environment}-eastus"
  description         = "Alerta para anomalias na VM"
  resource_group_name = var.resource_group_name
  scope_resource_ids  = [var.virtual_machine_id]
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT5M" # Ajustado para 5 minutos
  severity            = "Sev2"

  action_group {
    ids = [azurerm_monitor_action_group.action_group.id]
  }

  tags = {
    environment = var.environment
  }
}