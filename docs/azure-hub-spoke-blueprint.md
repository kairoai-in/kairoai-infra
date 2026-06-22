# Azure Hub-Spoke Blueprint

This repo implements the KairoAI Azure hub-spoke design after approval.

Source of truth for the current design is maintained in `kairoai-platform/your-brain/azure-hub-spoke-infra-design.md`.

## Subscriptions

| Environment | Subscription ID | Region |
| --- | --- | --- |
| Hub | `5b942f88-17e6-4026-ae23-d520365fb916` | Central India |
| Test | `6b01db76-626a-44a2-8119-17682410914a` | Central India |
| Prod | `a8270be7-dabc-4d92-98db-26a55025b0df` | Central India |
| Prod DR | `a8270be7-dabc-4d92-98db-26a55025b0df` | South India |

## Naming

Pattern:

```text
<resource-abbrev>-kairoai-<env>-<region-code>-<suffix>
```

Region codes:

- `ci` = Central India.
- `si` = South India.
- `global` = global service.

## Network CIDRs

| Network | CIDR |
| --- | --- |
| Hub | `10.10.0.0/16` |
| Test | `10.20.0.0/16` |
| Prod | `10.30.0.0/16` |
| Prod DR | `10.40.0.0/16` |

## Ingress

Required traffic path:

```text
Internet -> Azure Front Door -> Application Gateway WAF -> AKS
```

Demo default:

- Azure Front Door Premium.
- Separate test and prod routes.
- Application Gateway WAF public origin locked down to Front Door traffic.
- Keep Front Door Private Link hardening as a later phase.

## DR Level

Demo target is Level 2:

- DR resource group and VNet in South India.
- Database backup/failover path.
- Key Vault recovery plan.
- Front Door failover runbook.
- No warm standby AKS until budget/RTO requires it.

## Terraform Implementation Order

1. Bootstrap hub Terraform state.
2. Hub foundation: resource group, VNet, DNS, private DNS, ACR, Firewall, Bastion, Front Door.
3. Test spoke: VNet, peering, App Gateway WAF, AKS, PostgreSQL, Key Vault, Service Bus, AI Foundry, monitoring.
4. Validate application deploy on test.
5. Prod primary.
6. Prod DR.
7. Terraform pipelines after the first infrastructure path is stable.
