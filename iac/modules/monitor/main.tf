resource "azurerm_monitor_diagnostic_setting" "diagnostic" {
  name                       = "example-diagnostic"
  target_resource_id         = var.virtual_machine.id
  log_analytics_workspace_id = var.log_analytics_workspace.id


  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "alert" {
  name                         = "example-alert"
  description                  = "This is a sample alert"
  resource_group_name          = var.resource_group.name
  scope_resource_ids           = [var.virtual_machine.id]
  detector_type                = "FailureAnomaliesDetector"  # Corrigido para um tipo de detector válido
  frequency = "PT1M"  # Frequência de 1 hora
  severity                     = "Sev3"

  action_group {
    ids = [azurerm_monitor_action_group.example.id]
  }
}

resource "azurerm_monitor_action_group" "example" {
  name                = "example-ag"
  short_name          = "example-ag"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  email_receiver {
    name                   = "email_receiver"
    email_address          = "example@example.com"
    use_common_alert_schema = true
  }
}
