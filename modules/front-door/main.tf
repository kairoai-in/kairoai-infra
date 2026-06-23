terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  routes = {
    for name, route in var.routes : name => merge(route, {
      custom_domain_resource_name = replace(route.host_name, ".", "-")
    })
  }
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = local.routes

  name                     = each.value.custom_domain_resource_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  dns_zone_id              = var.dns_zone_id
  host_name                = each.value.host_name

  tls {
    certificate_type = "ManagedCertificate"
    minimum_version  = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = local.routes

  name                     = "${each.key}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 100
    path                = each.value.health_probe_path
    protocol            = each.value.forwarding_protocol == "HttpsOnly" ? "Https" : "Http"
    request_type        = "HEAD"
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = local.routes

  name                          = "${each.key}-app-gateway"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.key].id
  enabled                       = true

  certificate_name_check_enabled = each.value.forwarding_protocol == "HttpsOnly"
  host_name                      = each.value.origin_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = each.value.origin_host_header
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = local.routes

  name                          = "${each.key}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.key].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this[each.key].id]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.this[each.key].id]
  enabled                         = true
  forwarding_protocol             = each.value.forwarding_protocol
  https_redirect_enabled          = true
  link_to_default_domain          = each.value.link_to_default_domain
  patterns_to_match               = each.value.patterns_to_match
  supported_protocols             = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "this" {
  for_each = local.routes

  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.this[each.key].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.this[each.key].id]
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = "diag-${var.profile_name}"
  target_resource_id         = azurerm_cdn_frontdoor_profile.this.id
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

resource "azurerm_monitor_metric_alert" "origin_health_low" {
  count = var.metric_alerts_enabled ? 1 : 0

  name                = "alert-${var.profile_name}-origin-health-low"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_cdn_frontdoor_profile.this.id]
  description         = "Front Door origin health is below the configured threshold."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "OriginHealthPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.origin_health_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "latency_high" {
  count = var.metric_alerts_enabled ? 1 : 0

  name                = "alert-${var.profile_name}-latency-high"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_cdn_frontdoor_profile.this.id]
  description         = "Front Door total latency is above the configured threshold."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "TotalLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.latency_threshold_ms
  }

  action {
    action_group_id = var.action_group_id
  }
}
