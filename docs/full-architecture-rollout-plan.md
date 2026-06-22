# Full Architecture Rollout Plan

Last updated: `2026-06-22 23:06:29 +05:30`

This document treats KairoAI infrastructure as one complete architecture, not as isolated resources. Terraform still applies in dependency-safe waves because Azure resources depend on each other across subscriptions, but each wave belongs to the same target design.

## Target Architecture

```text
Internet
  -> Azure Front Door Premium
  -> Application Gateway WAF v2
  -> AKS ingress / services
  -> KairoAI microservices
  -> Azure PostgreSQL Flexible Server
  -> Azure Service Bus
  -> Azure AI Foundry / Azure AI Services
  -> Azure Monitor, Application Insights, Managed Grafana
```

## Subscription Ownership

| Subscription | Owns | Reason |
| --- | --- | --- |
| Hub | Terraform state, ACR, public DNS zone, private DNS zones, shared Key Vault, hub VNet, future global Front Door/security resources | Centralized shared services and cross-environment control plane. |
| Test spoke | Test VNet, AKS, App Gateway WAF, PostgreSQL, Key Vault, Service Bus, monitoring, AI Foundry test, workload identities, policy assignments | End-to-end validation before production. |
| Prod spoke | Production VNet, foundation subnets, PostgreSQL, Key Vault, Service Bus, monitoring, optional AKS/App Gateway WAF/Front Door/AI/workload identities/policy gates | Production runtime in Central India. |
| Prod DR | DR VNet, Key Vault recovery, DR observability, optional database/failover and warm standby AKS/App Gateway | Level 2 demo DR in South India, upgradeable to Level 3. |

## Rollout Waves

### Wave 0 - Bootstrap and Shared State

Status: mostly complete.

Creates or validates:

- `rg-kairoai-tfstate-ci`
- `stkairoaitfstateci`
- `hubtfstate`
- `testtfstate`
- `prodtfstate`
- backend keys for `hub`, `test`, `prod`, and `prod-dr`

Reason:

- Every environment needs a stable remote backend before team or pipeline execution.
- State is centralized in hub for governance and backup control.

### Wave 1 - Hub Foundation

Status: live for foundation; firewall, bastion, and Front Door still planned/deferred.

Creates:

- Hub resource group and VNet.
- Public DNS zone `kairoai.in`.
- Shared private DNS zones.
- ACR `acrkairoaihubci`.
- Hub Key Vault.
- Hub Log Analytics.

Remaining:

- Azure Front Door global profile and routes.
- Azure Firewall and Bastion if budget/operations require them.
- Private endpoints and stricter public network lock-down after private connectivity is fully validated.

Reason:

- Hub must exist before spokes can peer, resolve private DNS, pull images, and share global ingress/DNS.

### Wave 2 - Test Full Runtime

Status: partially live.

Live:

- Test RG/VNet/subnets.
- Hub-test VNet peering.
- Hub private DNS links.
- Key Vault.
- PostgreSQL Flexible Server.
- Service Bus namespace and queues.
- Log Analytics, Application Insights, Azure Monitor workspace, Managed Grafana.
- AKS with autoscaled system and user pools.
- Application Gateway WAF v2 with standalone WAF policy.

Remaining:

- Front Door route for `test.kairoai.in` and `api.test.kairoai.in`.
- AGIC or ingress integration between AKS and App Gateway.
- Private endpoints for Key Vault, Service Bus, ACR, Monitor, and any remaining PaaS resources.
- Azure AI Foundry / AI Services deployment.
- Workload identities for each application service.
- Azure Policy baseline assignments.
- Diagnostic settings and alerts for App Gateway and Front Door.
- Application deployment via Helm/Argo path.

Reason:

- Test is the proving ground for the complete platform before production.
- The full test path should validate `Front Door -> App Gateway WAF -> AKS -> services -> data/messaging/AI`.

### Wave 3 - Prod Primary

Status: reusable module root implemented and saved plan generated. Not applied.

Default plan creates the production foundation:

- `rg-kairoai-prod-ci`
- `vnet-kairoai-prod-ci`
- subnets for AKS system/user, App Gateway, private endpoints, PostgreSQL, private jobs.
- Hub-prod peering.
- Hub private DNS links.
- PostgreSQL Flexible Server.
- Key Vault.
- Service Bus.
- App Insights, Log Analytics or central workspace strategy.

Feature-gated for reviewed enablement:

- AKS private cluster with autoscaling.
- App Gateway WAF v2 with WAF policy.
- Azure Monitor workspace and Managed Grafana integration if prod-specific dashboards are required.
- Azure AI Foundry / AI Services prod deployment.
- Managed identities and federated credentials.
- Policy assignments.
- Front Door production routes for `kairoai.in` and `api.kairoai.in`.

Reason:

- Production should be a repeatable version of test with stronger security defaults, not a separately invented environment.

### Wave 4 - Prod DR

Status: reusable module root implemented and saved plan generated. Not applied.

Demo target: Level 2.

Default plan creates the Level 2 DR foundation:

- `rg-kairoai-prod-dr-si`
- `vnet-kairoai-prod-dr-si`
- DR subnets.
- Hub-DR peering.
- Private DNS links.
- Key Vault restore/recovery path.
- DR monitoring hooks and runbooks.

Feature-gated for reviewed enablement:

- PostgreSQL backup/failover foundation or replica path, depending on Azure feature/quota fit.
- DR Service Bus namespace.
- Warm standby AKS.
- DR App Gateway WAF.
- Azure AI Foundry / AI Services.
- DR Front Door origin/failover route.

Reason:

- Level 2 is credible for demo without paying for a full warm standby runtime.
- Level 3 can be added without redesigning the network/module layout.

### Wave 5 - CI/CD and Policy Automation

Status: intentionally after first manual path.

Create:

- GitHub OIDC federated identities per environment.
- Terraform PR plan pipelines.
- Manual approval apply pipelines.
- OPA/Conftest checks.
- Checkov/Terraform security checks.
- Azure Policy compliance checks.
- Slack notifications.

Reason:

- Pipelines should automate a proven path, not discover architecture issues while applying production infrastructure.

## Full Resource Matrix

| Layer | Hub | Test | Prod | Prod DR |
| --- | --- | --- | --- | --- |
| State | Live | Uses hub backend | Uses hub backend | Uses hub backend |
| DNS | Public + private DNS live | Linked to hub private DNS | Planned links | Planned links |
| Network | Hub VNet live | Spoke VNet live | Planned | Planned |
| Peering | Hub-test live | Hub-test live | Planned hub-prod | Planned hub-prod-dr |
| ACR | Live shared ACR | Pulls from hub ACR | Pulls from hub ACR | Pulls from hub ACR |
| AKS | N/A | Live | Planned | Optional Level 3 |
| App Gateway WAF | N/A | Live | Planned | Optional Level 3 |
| Front Door | Planned global | Planned test route | Planned prod route | Planned failover route |
| PostgreSQL | N/A | Live | Planned | Planned Level 2 |
| Service Bus | N/A | Live | Planned | Optional DR namespace |
| Key Vault | Live shared hub KV | Live | Planned | Planned recovery |
| AI Foundry | N/A or shared future | Planned | Planned | Optional |
| Monitoring | Hub LAW live | LAW/AppI/AMW/Grafana live | Planned | Planned |
| Managed identities | Planned | Planned | Planned | Planned |
| Policy | Planned | Planned | Planned | Planned |

## Terraform Strategy

We should plan the whole architecture in code, but apply in controlled waves:

1. Update module contracts once and reuse everywhere.
2. Expand `prod` and `prod-dr` roots to match `test` module composition.
3. Keep high-cost optional resources behind explicit variables.
4. Run `terraform validate` for all roots.
5. Generate plans for `hub`, `test`, `prod`, and `prod-dr`.
6. Review all plans together.
7. Apply in dependency order:
   - hub
   - test
   - prod
   - prod-dr
8. Re-run all plans and require `No changes`.

This gives us one architecture review while still respecting Azure dependencies and cost controls.

## Current Plan Review

Completed in code:

1. Refactored `prod` and `prod-dr` roots to use the same reusable modules as `test`.
2. Added shared environment variables for feature gates and SKU choices.
3. Added backend configuration for `prod` and `prod-dr` in the hub `prodtfstate` container.
4. Ran a combined validation and saved-plan pass across all roots.

Saved plan status:

| Root | Saved plan | Create | Update | Delete | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| `hub` | `hub-full-architecture.tfplan` | 0 | 0 | 0 | Existing hub remains unchanged. |
| `test` | `test-full-architecture.tfplan` | 0 | 0 | 0 | Existing test runtime remains unchanged. |
| `prod` | `prod-full-architecture.tfplan` | 29 | 0 | 0 | Creates production foundation only; AKS/App Gateway/Front Door/AI are gated off. |
| `prod-dr` | `prod-dr-full-architecture.tfplan` | 21 | 0 | 0 | Creates Level 2 DR foundation only; warm runtime is gated off. |

## Immediate Next Implementation Step

1. Add diagnostic settings for App Gateway WAF and Front Door modules.
2. Decide whether Front Door lives only in hub/global root or is composed from spoke roots using origin outputs.
3. Add first Azure Policy assignment set and OPA checks.
4. Review and apply `prod`, then `prod-dr`, if costs and resource list look good.

## Safety Rules

- Do not apply production until all environment plans are reviewed together.
- Keep App Gateway and Front Door enabled only where the target state is intentionally live.
- Never use `-var` to create a long-lived resource unless the committed defaults or tfvars are updated immediately after.
- Every apply must be followed by a plain `terraform plan` with no ad-hoc vars.
- Record each architecture-level decision in this file or `kairoai-platform/your-brain/decisions.md`.
