terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  backend_pool_name      = "default-backend-pool"
  frontend_ip_name       = "public-frontend-ip"
  frontend_port_name     = "http"
  http_listener_name     = "http-listener"
  http_settings_name     = "http-settings"
  request_rule_name      = "default-http-rule"
  gateway_ip_config_name = "gateway-ip-configuration"
  waf_policy_name        = coalesce(var.waf_policy_name, "policy-${var.name}")
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = []
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "this" {
  name                = local.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  custom_rules {
    name      = "AllowSignedGitHubWebhooks"
    priority  = 50
    rule_type = "MatchRule"
    action    = "Allow"
    enabled   = true

    match_conditions {
      match_variables {
        variable_name = "RequestUri"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["/api/github/events"]
    }

    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "x-hub-signature-256"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["sha256="]
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestCookieNames"
      selector                = "kairoai_installation"
      selector_match_operator = "Equals"

      excluded_rule_set {
        type    = "OWASP"
        version = "3.2"

        rule_group {
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
          excluded_rules = [
            "942200",
            "942260",
            "942340",
            "942370",
          ]
        }
      }
    }

    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  firewall_policy_id  = azurerm_web_application_firewall_policy.this.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_config_name
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  backend_address_pool {
    name  = local.backend_pool_name
    fqdns = var.backend_fqdns
  }

  backend_http_settings {
    name                  = local.http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.http_settings_name
    priority                   = 100
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      redirect_configuration,
      rewrite_rule_set,
      tags["managed-by-k8s-ingress"],
      url_path_map,
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories

    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_metric_alert" "unhealthy_hosts" {
  count = var.action_group_id == null ? 0 : 1

  name                = "alert-${var.name}-unhealthy-hosts"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.this.id]
  description         = "Application Gateway has unhealthy backend hosts."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT5M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.unhealthy_host_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "failed_requests" {
  count = var.action_group_id == null ? 0 : 1

  name                = "alert-${var.name}-failed-requests"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.this.id]
  description         = "Application Gateway failed requests exceeded the configured threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "FailedRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.failed_requests_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}
