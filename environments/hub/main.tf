locals {
  region_code = "ci"

  names = {
    resource_group            = "rg-kairoai-hub-ci"
    vnet                      = "vnet-kairoai-hub-ci"
    firewall                  = "afw-kairoai-hub-ci"
    firewall_policy           = "afwp-kairoai-hub-ci"
    bastion                   = "bas-kairoai-hub-ci"
    acr                       = "acrkairoaihubci"
    front_door                = "afd-kairoai-global"
    public_dns_zone           = "kairoai.in"
    terraform_state_rg        = "rg-kairoai-tfstate-ci"
    terraform_state_storage   = "stkairoaitfstateci"
    terraform_state_container = "tfstate"
  }

  subnets = {
    AzureFirewallSubnet           = "10.10.0.0/26"
    AzureFirewallManagementSubnet = "10.10.0.64/26"
    AzureBastionSubnet            = "10.10.1.0/26"
    private_endpoints             = "10.10.2.0/24"
    shared_services               = "10.10.3.0/24"
  }

  tags = merge(
    {
      application         = "kairoai"
      environment         = var.environment
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "internal"
      criticality         = "high"
      region              = var.location
    },
    var.tags,
  )
}

# Implementation checkpoint:
# This root currently captures the approved hub naming/network contract.
# Resource creation will be added module-by-module after the bootstrap/state path is approved.
