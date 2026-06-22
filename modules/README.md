# Terraform Modules

Modules should be small, composable, and environment-agnostic.

## Planned Modules

- `naming`
- `resource-group`
- `networking`
- `vnet-peering`
- `firewall`
- `private-dns`
- `acr`
- `front-door`
- `app-gateway-waf`
- `aks`
- `postgresql-flexible`
- `key-vault`
- `service-bus`
- `monitor`
- `ai-foundry`
- `managed-identity`
- `policy`

## Rules

- No module should assume a subscription implicitly.
- Provider aliases should be passed from root modules.
- Tags must be applied consistently.
- Private endpoint support should be explicit.
- Public access must default to disabled for production-grade PaaS services unless the root module intentionally enables it.
