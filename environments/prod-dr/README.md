# Production DR Environment

Subscription: `a8270be7-dabc-4d92-98db-26a55025b0df`

Region: South India

## Planned Resources

- `rg-kairoai-prod-dr-si`
- `vnet-kairoai-prod-dr-si`
- VNet peering to hub
- PostgreSQL DR/failover resources
- Key Vault recovery path
- Optional Application Gateway WAF
- Optional warm standby AKS after demo
- DR diagnostics and failover runbooks

## State Key

`prodtfstate/kairoai/prod-dr/terraform.tfstate`
