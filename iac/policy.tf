resource "azurerm_policy_definition" "require_tags" {
  name         = "require-caf-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Exigir tags CAF em todos os recursos"

  policy_rule = <<POLICY_RULE
  {
    "if": {
      "allOf": [
        {
          "field": "tags['environment']",
          "exists": "false"
        },
        {
          "field": "tags['project']",
          "exists": "false"
        },
        {
          "field": "tags['owner']",
          "exists": "false"
        },
        {
          "field": "tags['cost_center']",
          "exists": "false"
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY_RULE
}

resource "azurerm_resource_group_policy_assignment" "require_tags_assignment" {
  name                 = "require-caf-tags-assignment"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Força a aplicação de tags CAF em todos os recursos no grupo de recursos"
  display_name         = "Forçar Tags CAF"
}