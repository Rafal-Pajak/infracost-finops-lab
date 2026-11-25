data "azurerm_subscription" "current" {}

resource "azurerm_monitor_action_group" "finops_alerts" {
  name                = "ag-finops-budget-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "FinOpsAlert"

  email_receiver {
    name                    = "finops-lead"
    email_address           = "finops-alerts@example.com"
    use_common_alert_schema = true
  }

  tags = local.common_tags
}

resource "azurerm_consumption_budget_subscription" "monthly_guardrail" {
  name            = "budget-sub-finops-40eur"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 40
  time_grain = "Monthly"

  time_period {
    start_date = "2026-11-01T00:00:00Z"
    end_date   = "2027-11-01T00:00:00Z"
  }

  filter {
    tag {
      name = "Environment"
      values = [
        "prod",
        "lab"
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_groups = [
      azurerm_monitor_action_group.finops_alerts.id
    ]
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_groups = [
      azurerm_monitor_action_group.finops_alerts.id
    ]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.finops_alerts.id
    ]
  }
}
