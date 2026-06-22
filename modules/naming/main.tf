locals {
  base        = "${var.workload}-${var.environment}-${var.region_code}"
  clean_extra = replace(var.suffix, "-", "")
  public_host = var.environment == "prod" ? var.public_domain : "${var.environment}.${var.public_domain}"

  names = {
    resource_group        = "rg-${local.base}"
    vnet                  = "vnet-${local.base}"
    aks                   = "aks-${local.base}"
    aks_node_rg           = "rg-${local.base}-aks-nodes"
    app_gateway           = "agw-${local.base}"
    public_ip             = "pip-${local.base}"
    postgresql            = "psql-${local.base}"
    key_vault             = substr("kv-${local.base}${local.clean_extra}", 0, 24)
    service_bus           = "sb-${local.base}"
    log_analytics         = "law-${local.base}"
    app_insights          = "appi-${local.base}"
    monitor_workspace     = "amw-${local.base}"
    managed_grafana       = "amg-${local.base}"
    ai_foundry            = "oai-${local.base}"
    front_door_host       = local.public_host
    front_door_api_host   = "api.${local.public_host}"
    front_door_profile    = "afd-${local.base}"
    front_door_endpoint   = "fde-${local.base}"
    action_group_platform = "ag-${var.workload}-${var.environment}-platform"
  }
}
