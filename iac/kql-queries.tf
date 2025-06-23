resource "azurerm_log_analytics_saved_search" "weblogic_errors" {
  name                       = "weblogic-errors"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  category     = "WebLogic"
  display_name = "Erros do WebLogic"
  query        = <<QUERY
AppTraces
| where AppRoleName == "WebLogic"
| where SeverityLevel == "Error"
| summarize count() by OperationName, Timestamp
| order by Timestamp desc
QUERY
}

resource "azurerm_log_analytics_saved_search" "weblogic_login_failures" {
  name                       = "weblogic-login-failures"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  category     = "WebLogic"
  display_name = "Falhas de Login no WebLogic"
  query        = <<QUERY
SigninLogs
| where AppDisplayName == "WebLogic"
| where ResultType != "0"
| summarize count() by UserPrincipalName, ResultDescription
QUERY
}