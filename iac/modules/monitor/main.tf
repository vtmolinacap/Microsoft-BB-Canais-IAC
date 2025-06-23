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

  enabled_log {
    category = "LinuxSyslog"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "LinuxSyslogEvents"

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
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "alert" {
  name                = "alert-${var.environment}-eastus"
  description         = "Alerta para anomalias na VM"
  resource_group_name = var.resource_group_name
  scope_resource_ids  = [var.virtual_machine_id]
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT15M"
  severity            = "Sev2"

  action_group {
    ids = [azurerm_monitor_action_group.action_group.id]
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${var.environment}-eastus"
  resource_group_name = var.resource_group_name
  scopes              = [var.virtual_machine_id]
  description         = "Alerta para uso elevado de CPU"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "memory-alert-${var.environment}-eastus"
  resource_group_name = var.resource_group_name
  scopes              = [var.virtual_machine_id]
  description         = "Alerta para pouca memória disponível"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100000000 # 100 MB
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}

resource "azurerm_monitor_metric_alert" "weblogic_jvm" {
  name                = "weblogic-jvm-alert-${var.environment}-eastus"
  resource_group_name = var.resource_group_name
  scopes              = [var.virtual_machine_id]
  description         = "Alerta para uso elevado de heap do JVM no WebLogic"

  criteria {
    metric_namespace = "azure.applicationinsights"
    metric_name      = "process.memory.heap.used"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  tags = {
    environment = var.environment
    project     = "suse-weblogic"
    owner       = "it-team"
    cost_center = "12345"
  }
}