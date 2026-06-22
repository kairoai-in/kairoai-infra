locals {
  region_code = "ci"

  names = {
    resource_group      = "rg-kairoai-prod-ci"
    vnet                = "vnet-kairoai-prod-ci"
    aks                 = "aks-kairoai-prod-ci"
    app_gateway         = "agw-kairoai-prod-ci"
    postgresql          = "psql-kairoai-prod-ci"
    key_vault           = "kv-kairoai-prod-ci"
    service_bus         = "sb-kairoai-prod-ci"
    app_insights        = "appi-kairoai-prod-ci"
    ai_foundry          = "oai-kairoai-prod-ci"
    front_door_host     = "kairoai.in"
    front_door_api_host = "api.kairoai.in"
  }

  subnets = {
    aks_system         = "10.30.0.0/22"
    aks_user           = "10.30.4.0/21"
    app_gateway        = "10.30.12.0/24"
    private_endpoints  = "10.30.13.0/24"
    postgres_delegated = "10.30.14.0/24"
    aci_private        = "10.30.15.0/24"
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
    },
    var.tags,
  )
}

# Implementation checkpoint:
# This root currently captures the approved prod spoke naming/network contract.
