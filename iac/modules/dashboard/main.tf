resource "azurerm_portal_dashboard" "vm_dashboard" {
  name                = "dash-${var.environment}-eastus"
  resource_group_name = var.resource_group_name
  location            = "eastus"

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "1" = {
            position = {
              x      = 0
              y      = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = "# Dashboard da VM (${var.environment})"
              }
            }
          }
          "2" = {
            position = {
              x      = 0
              y      = 4
              rowSpan = 6
              colSpan = 6
            }
            metadata = {
              type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
              settings = {
                content = {
                  Version   = "1.0"
                  ChartType = "LineChart"
                  Metrics = [
                    {
                      ResourceId    = var.virtual_machine_id
                      MetricNamespace = "Microsoft.Compute/virtualMachines"
                      MetricName     = "Percentage CPU"
                      Aggregation    = "Average"
                    }
                  ]
                  Title = "Uso de CPU"
                }
              }
            }
          }
          "3" = {
            position = {
              x      = 6
              y      = 4
              rowSpan = 6
              colSpan = 6
            }
            metadata = {
              type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
              settings = {
                content = {
                  Version   = "1.0"
                  ChartType = "LineChart"
                  Metrics = [
                    {
                      ResourceId    = var.nic_id
                      MetricNamespace = "Microsoft.Network/networkInterfaces"
                      MetricName     = "Network In Total"
                      Aggregation    = "Total"
                    },
                    {
                      ResourceId    = var.nic_id
                      MetricNamespace = "Microsoft.Network/networkInterfaces"
                      MetricName     = "Network Out Total"
                      Aggregation    = "Total"
                    }
                  ]
                  Title = "Tráfego de Rede"
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            durationMs = var.time_range_ms
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })

  tags = {
    environment = var.environment
  }
}