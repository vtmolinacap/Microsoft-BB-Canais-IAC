output "diagnostic_setting_id" {
  description = "ID da configuração de diagnóstico"
  value       = azurerm_monitor_diagnostic_setting.diagnostic.id
}

output "alert_rule_id" {
  description = "ID da regra de alerta"
  value       = azurerm_monitor_smart_detector_alert_rule.alert.id
}