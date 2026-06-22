locals {
  region_code = "ci"

  names = {
    resource_group      = "rg-kairoai-test-ci"
    vnet                = "vnet-kairoai-test-ci"
    aks                 = "aks-kairoai-test-ci"
    app_gateway         = "agw-kairoai-test-ci"
    postgresql          = "psql-kairoai-test-ci"
    key_vault           = "kv-kairoai-test-ci"
    service_bus         = "sb-kairoai-test-ci"
    app_insights        = "appi-kairoai-test-ci"
    ai_foundry          = "oai-kairoai-test-ci"
    front_door_host     = "test.kairoai.in"
    front_door_api_host = "api.test.kairoai.in"
  }

  subnets = {
    aks_system         = "10.20.0.0/22"
    aks_user           = "10.20.4.0/21"
    app_gateway        = "10.20.12.0/24"
    private_endpoints  = "10.20.13.0/24"
    postgres_delegated = "10.20.14.0/24"
    aci_private        = "10.20.15.0/24"
  }

  tags = merge(
    {
      application         = "kairoai"
      environment         = var.environment
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "internal"
      criticality         = "medium"
      region              = var.location
    },
    var.tags,
  )
}

# Implementation checkpoint:
# This root currently captures the approved test spoke naming/network contract.
