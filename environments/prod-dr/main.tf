locals {
  region_code = "si"

  names = {
    resource_group      = "rg-kairoai-prod-dr-si"
    vnet                = "vnet-kairoai-prod-dr-si"
    aks                 = "aks-kairoai-prod-dr-si"
    app_gateway         = "agw-kairoai-prod-dr-si"
    postgresql          = "psql-kairoai-prod-dr-si"
    key_vault           = "kv-kairoai-proddr-si"
    service_bus         = "sb-kairoai-prod-dr-si"
    app_insights        = "appi-kairoai-prod-dr-si"
    ai_foundry          = "oai-kairoai-prod-dr-si"
    front_door_host     = "dr.kairoai.in"
    front_door_api_host = "api.dr.kairoai.in"
  }

  subnets = {
    aks_system         = "10.40.0.0/22"
    aks_user           = "10.40.4.0/21"
    app_gateway        = "10.40.12.0/24"
    private_endpoints  = "10.40.13.0/24"
    postgres_delegated = "10.40.14.0/24"
  }

  tags = merge(
    {
      application         = "kairoai"
      environment         = var.environment
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "confidential"
      criticality         = "high"
      region              = var.location
      dr_level            = "2"
    },
    var.tags,
  )
}

# Implementation checkpoint:
# This root currently captures the approved prod DR naming/network contract.
