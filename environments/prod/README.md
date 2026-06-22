# Production Primary Environment

Subscription: `a8270be7-dabc-4d92-98db-26a55025b0df`

Region: Central India

## Planned Resources

- `rg-kairoai-prod-ci`
- `vnet-kairoai-prod-ci`
- VNet peering to hub
- Application Gateway WAF v2 with AGIC
- AKS production cluster with system and user node pools
- Azure PostgreSQL Flexible Server
- Key Vault
- Service Bus
- Azure AI Foundry/OpenAI
- Application Insights and diagnostics
- Private endpoints and private DNS links

## State Key

`prodtfstate/kairoai/prod/terraform.tfstate`
