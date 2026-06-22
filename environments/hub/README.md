# Hub Environment

Subscription: `5b942f88-17e6-4026-ae23-d520365fb916`

Region: Central India

## Planned Resources

- `rg-kairoai-hub-ci`
- `vnet-kairoai-hub-ci`
- Azure Firewall and Firewall Policy
- Azure Bastion
- Azure DNS public zone for `kairoai.in`
- Private DNS zones
- Azure Container Registry
- Azure Front Door Premium
- Terraform state storage account
- Hub Key Vault if needed for platform secrets
- Central diagnostics and policy assignments

## State Key

`hubtfstate/kairoai/hub/terraform.tfstate`
