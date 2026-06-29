# Full Architecture Rollout Plan

Last updated: `2026-06-23 17:47:56 +05:30`

This document treats KairoAI infrastructure as one complete architecture, not as isolated resources. Terraform still applies in dependency-safe waves because Azure resources depend on each other across subscriptions, but each wave belongs to the same target design.

For the detailed browser-to-AKS request path, see `public-dns-and-ingress-flow.md`.

## Target Architecture

```text
User browser
  -> kairoai.in / api.kairoai.in / test.kairoai.in / test-api.kairoai.in
  -> GoDaddy registrar delegation
  -> Azure DNS zone kairoai.in in hub subscription
  -> Azure Front Door Premium profile afd-kairoai-global
  -> Azure Front Door endpoint fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
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
| Hub | Terraform state, ACR, public DNS zone, private DNS zones, shared Key Vault, hub VNet, shared global Front Door/security resources | Centralized shared services and cross-environment control plane. |
| Test spoke | Test VNet, AKS, App Gateway WAF, PostgreSQL, Key Vault, Service Bus, monitoring, AI Foundry test, workload identities, policy assignments | End-to-end validation before production. |
| Prod spoke | Production VNet, AKS, App Gateway WAF, PostgreSQL, Key Vault, Service Bus, monitoring, AI Services, optional workload identities/policy gates | Production runtime in Central India with the AI account placed in South India for available pay-as-you-go model quota. |
| Prod DR | DR VNet, Key Vault recovery, DR observability, optional database/failover and warm standby AKS/App Gateway | Level 2 demo DR in South India, upgradeable to Level 3. |

## Diagram Resource Inventory

Use this section as the source for an architecture diagram. The recommended visual grouping is by subscription boundary first, then by resource group, VNet, and subnet.

### Global Flow

```text
Users / GitHub
  -> GoDaddy domain registration for kairoai.in
  -> Custom nameserver delegation to Azure DNS:
       ns1-05.azure-dns.com.
       ns2-05.azure-dns.net.
       ns3-05.azure-dns.org.
       ns4-05.azure-dns.info.
  -> Azure DNS public zone kairoai.in in hub subscription
       @        A/ALIAS -> Azure Front Door endpoint resource
       api      CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
       test     CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
       test-api CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
       _dnsauth TXT     -> Front Door managed certificate validation
  -> Azure Front Door Premium profile afd-kairoai-global
  -> Azure Front Door endpoint fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
  -> Hostname-based route:
       kairoai.in       -> prod dashboard origin
       api.kairoai.in   -> prod API origin
       test.kairoai.in  -> test dashboard origin
       test-api.kairoai.in -> test API origin
  -> Application Gateway WAF v2 in the selected spoke
  -> AKS ingress / AGIC
  -> KairoAI services
  -> Azure PostgreSQL Flexible Server
  -> Azure Service Bus queues
  -> Azure AI Foundry / Azure AI Services
  -> Azure Monitor / Log Analytics / Application Insights / Managed Grafana
```

### Hub Subscription - `kairoai-hub-subscription`

| Layer | Resource | Planned Name | Status | Diagram Notes |
| --- | --- | --- | --- | --- |
| State | Resource group | `rg-kairoai-tfstate-ci` | Live | Draw as shared Terraform backend control-plane RG. |
| State | Storage account | `stkairoaitfstateci` | Live | Secure remote state storage. |
| State | Blob containers | `hubtfstate`, `testtfstate`, `prodtfstate` | Live | One container per environment family. |
| Shared RG | Resource group | `rg-kairoai-hub-ci` | Live | Hub shared services RG. |
| Network | VNet | `vnet-kairoai-hub-ci` `10.10.0.0/16` | Live | Center of hub-spoke diagram. |
| DNS | Public DNS zone | `kairoai.in` | Live | Authoritative DNS zone after GoDaddy delegates to Azure DNS nameservers `ns1-05.azure-dns.com`, `ns2-05.azure-dns.net`, `ns3-05.azure-dns.org`, and `ns4-05.azure-dns.info`. |
| DNS | Private DNS zones | `private.postgres.database.azure.com`, `privatelink.azurecr.io`, `privatelink.blob.core.windows.net`, `privatelink.monitor.azure.com`, `privatelink.ods.opinsights.azure.com`, `privatelink.postgres.database.azure.com`, `privatelink.servicebus.windows.net`, `privatelink.vaultcore.azure.net` | Live | Link each spoke VNet to these zones. |
| Registry | Azure Container Registry | `acrkairoaihubci` | Live | Shared image registry for test/prod/prod-dr. |
| Secrets | Key Vault | `kv-kairoai-hub-ci` | Live | Shared control-plane certificates and automation references only; never stores test/prod workload secrets. |
| Observability | Log Analytics | `law-kairoai-hub-ci` | Live | Hub control-plane logs. |
| Edge | Azure Front Door Premium | `afd-kairoai-global` / `fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net` | Live | `afd-kairoai-global` is the Front Door profile. `fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net` is the Azure-generated endpoint hostname that custom DNS records target. |
| DNS | Front Door DNS records | `@`, `api`, `test`, `test-api`, `_dnsauth*` in `kairoai.in` | Live | Apex `@` uses an Azure DNS alias A record to the Front Door endpoint resource. `api`, `test`, and `test-api` are CNAMEs to the Front Door endpoint hostname. `_dnsauth*` TXT records validate Front Door managed certificates. |
| Observability | Front Door diagnostic setting | `diag-afd-kairoai-global` | Live | Sends Front Door access and health probe logs to hub Log Analytics. |
| Observability | Front Door alerts | `alert-afd-kairoai-global-origin-health-low`, `alert-afd-kairoai-global-latency-high` | Live | Shared global edge health and latency alerts. |
| Security | Azure Firewall | `afw-kairoai-hub-ci` / `afwp-kairoai-hub-ci` | Deferred | Do not deploy now. Names/subnets are reserved in Terraform, but the Firewall module is still a placeholder and no Firewall resources are deployed. |
| Operations | Azure Bastion | `bas-kairoai-hub-ci` | Deferred | Do not deploy now. `AzureBastionSubnet` is reserved, but no Bastion resource is deployed until private browser SSH/RDP is required. |

### Test Spoke - `kairoai-test-subscription`

| Layer | Resource | Planned Name | Status | Diagram Notes |
| --- | --- | --- | --- | --- |
| RG | Resource group | `rg-kairoai-test-ci` | Live | Single test runtime RG. |
| Network | VNet | `vnet-kairoai-test-ci` `10.20.0.0/16` | Live | Peered with hub VNet. |
| Network | AKS system subnet | `snet-aks-system` `10.20.0.0/22` | Live | AKS system node pool. |
| Network | AKS user subnet | `snet-aks-user` `10.20.16.0/21` | Live | App workloads. |
| Network | App Gateway subnet | `snet-app-gateway` `10.20.12.0/24` | Live | Dedicated Application Gateway subnet. |
| Network | Private endpoints subnet | `snet-private-endpoints` `10.20.13.0/24` | Live | Future private endpoints. |
| Network | PostgreSQL delegated subnet | `snet-postgres-delegated` `10.20.14.0/24` | Live | PostgreSQL Flexible Server VNet injection. |
| Network | Private jobs subnet | `snet-aci-private` `10.20.15.0/24` | Live | Private job/container execution reserve. |
| Peering | Hub-test VNet peering | `peer-vnet-kairoai-test-ci-to-vnet-kairoai-hub-ci` and reverse | Live | Bidirectional hub-spoke peering. |
| DNS | Private DNS links | `link-*-test` | Live | Links test VNet to hub private DNS zones. |
| AKS | Cluster | `aks-kairoai-test-ci` | Live | Private cluster with autoscaled system/user pools. |
| Edge | Public IP | `pip-kairoai-test-ci` | Live | App Gateway frontend IP. |
| Edge | Application Gateway WAF | `agw-kairoai-test-ci` | Live | Regional WAF before AKS. |
| Edge | WAF policy | `policy-agw-kairoai-test-ci` | Live | OWASP managed rules in Prevention mode. |
| Edge | Front Door route | Shared hub `afd-kairoai-global` | Live | Hub route maps `test.kairoai.in` and `test-api.kairoai.in` to test App Gateway `13.71.2.80`. |
| Data | PostgreSQL Flexible Server | `psql-kairoai-test-ci` | Live | Private database server. |
| Data | PostgreSQL database | `kairoai` | Live | App database. |
| Messaging | Service Bus namespace | `sb-kairoai-test-ci` | Live | Async app messaging. |
| Messaging | Service Bus queues | `review-jobs`, `analysis-results` | Live | Review workflow queues. |
| Messaging | Runtime queue | `review-analysis` | Live | Application-contract queue with queue-scoped Send+Listen authorization. |
| Secrets | Key Vault | `kv-kairoai-test-ci` | Live | Test runtime secrets. |
| Secrets | Runtime secret entries | `database-url`, `service-bus-connection-string` | Live | Generated by Terraform and stored only in test Key Vault. |
| AI | Azure AI Foundry / AI Services | `oai-kairoai-test-ci` | Planned | AI suggestions and explanations. |
| Observability | Log Analytics | `law-kairoai-test-ci` | Live | Test logs. |
| Observability | Application Insights | `appi-kairoai-test-ci` | Live | App telemetry. |
| Observability | Azure Monitor workspace | `amw-kairoai-test-ci` | Live | Managed Prometheus metrics. |
| Observability | Managed Grafana | `amg-kairoai-test-ci` | Live | Dashboards. |
| Observability | Action group | `ag-kairoai-test-platform` | Live | Alert routing. |
| Observability | App Gateway diagnostic setting | `diag-agw-kairoai-test-ci` | Planned | Sends access, performance, firewall logs, and metrics to Log Analytics. |
| Observability | App Gateway alerts | `alert-agw-kairoai-test-ci-unhealthy-hosts`, `alert-agw-kairoai-test-ci-failed-requests` | Planned | Regional edge health alerts. |
| Governance | Managed identities | `id-*` | Planned | Workload identity and GitHub OIDC. |
| Governance | Azure Policy assignments | From `policy_assignments` | Planned | Resource-group scoped guardrails. |

### Prod Spoke - `kairoai-prod-subscription`

| Layer | Resource | Planned Name | Status | Diagram Notes |
| --- | --- | --- | --- | --- |
| RG | Resource group | `rg-kairoai-prod-ci` | Live | Production primary RG. |
| Network | VNet | `vnet-kairoai-prod-ci` `10.30.0.0/16` | Live | Peered with hub VNet. |
| Network | AKS system subnet | `snet-aks-system` `10.30.0.0/22` | Live | AKS system nodes. |
| Network | AKS user subnet | `snet-aks-user` `10.30.16.0/21` | Live | App workloads. |
| Network | App Gateway subnet | `snet-app-gateway` `10.30.12.0/24` | Live | Dedicated App Gateway WAF subnet. |
| Network | Private endpoints subnet | `snet-private-endpoints` `10.30.13.0/24` | Live | Private endpoints. |
| Network | PostgreSQL delegated subnet | `snet-postgres-delegated` `10.30.14.0/24` | Live | PostgreSQL Flexible Server. |
| Network | Private jobs subnet | `snet-aci-private` `10.30.15.0/24` | Live | Private jobs reserve. |
| Peering | Hub-prod VNet peering | `peer-vnet-kairoai-prod-ci-to-vnet-kairoai-hub-ci` and reverse | Live | Bidirectional hub-spoke peering. |
| DNS | Private DNS links | `link-*-prod` | Live | Links prod VNet to hub private DNS zones. |
| AKS | Cluster | `aks-kairoai-prod-ci` | Live | Private cluster, autoscaled system/user pools, managed AGIC enabled. |
| Edge | Public IP | `pip-kairoai-prod-ci` `20.219.35.127` | Live | App Gateway frontend IP. |
| Edge | Application Gateway WAF | `agw-kairoai-prod-ci` | Live | Regional WAF before AKS. |
| Edge | WAF policy | `policy-agw-kairoai-prod-ci` | Live | OWASP managed rules in Prevention mode. |
| Edge | Front Door route | Shared hub `afd-kairoai-global` | Live | Hub route maps `kairoai.in` and `api.kairoai.in` to prod App Gateway `20.219.35.127` with separate host headers. |
| Data | PostgreSQL Flexible Server | `psql-kairoai-prod-ci` | Live | Production app database. |
| Data | PostgreSQL database | `kairoai` | Live | App database. |
| Messaging | Service Bus namespace | `sb-kairoai-prod-ci` | Live | Premium async messaging with capacity `1` and partition `1`. |
| Messaging | Service Bus queues | `review-jobs`, `analysis-results` | Live | Review workflow queues. |
| Messaging | Runtime queue | `review-analysis` | Live | Application-contract queue with queue-scoped Send+Listen authorization. |
| Secrets | Key Vault | `kv-kairoai-prod-ci` | Live | Production runtime secrets. |
| Secrets | Runtime secret entries | `database-url`, `service-bus-connection-string`, `azure-ai-foundry-endpoint`, `azure-ai-foundry-api-key`, `azure-ai-foundry-api-version`, `azure-ai-foundry-deployment` | Live | Generated by Terraform and stored only in prod Key Vault. |
| AI | Azure AI Foundry / AI Services | `oai-kairoai-prod-si` | Live | South India account using `GlobalStandard`; GPT-5.4 primary and GPT-5.4-mini fallback, capacity 10 each. |
| Observability | Log Analytics | `law-kairoai-prod-ci` | Live | Production logs. |
| Observability | Application Insights | `appi-kairoai-prod-ci` | Live | Production telemetry. |
| Observability | Action group | `ag-kairoai-prod-platform` | Live | Alert routing. |
| Observability | App Gateway diagnostic setting | `diag-agw-kairoai-prod-ci` | Live | Sends access, performance, firewall logs, and metrics to Log Analytics. |
| Observability | App Gateway alerts | `alert-agw-kairoai-prod-ci-unhealthy-hosts`, `alert-agw-kairoai-prod-ci-failed-requests` | Live | Regional edge health alerts. |
| Governance | Managed identities | `id-*` | Feature-gated | Workload identity and GitHub OIDC. |
| Governance | Platform admin group | `grp-kairoai-platform-admins` | Live | Group-based AKS data-plane administration; no direct human role assignment. |
| Governance | Azure Policy assignments | From `policy_assignments` | Feature-gated | Resource-group scoped guardrails. |

### Prod DR - `kairoai-prod-subscription`

| Layer | Resource | Planned Name | Status | Diagram Notes |
| --- | --- | --- | --- | --- |
| RG | Resource group | `rg-kairoai-prod-dr-si` | Live | South India DR RG. |
| Network | VNet | `vnet-kairoai-prod-dr-si` `10.40.0.0/16` | Live | Peered with hub VNet. |
| Network | AKS system subnet | `snet-aks-system` `10.40.0.0/22` | Live | Warm standby reserve. |
| Network | AKS user subnet | `snet-aks-user` `10.40.16.0/21` | Live | Warm standby reserve. |
| Network | App Gateway subnet | `snet-app-gateway` `10.40.12.0/24` | Live | DR App Gateway reserve. |
| Network | Private endpoints subnet | `snet-private-endpoints` `10.40.13.0/24` | Live | DR private endpoints. |
| Network | PostgreSQL delegated subnet | `snet-postgres-delegated` `10.40.14.0/24` | Live | DR DB/failover reserve. |
| Peering | Hub-DR VNet peering | `peer-vnet-kairoai-prod-dr-si-to-vnet-kairoai-hub-ci` and reverse | Live | Bidirectional hub-spoke peering. |
| DNS | Private DNS links | `link-*-prod-dr` | Live | Links DR VNet to hub private DNS zones. |
| AKS | Cluster | `aks-kairoai-prod-dr-si` | Feature-gated | Optional Level 3 warm standby. |
| Edge | Public IP | `pip-kairoai-prod-dr-si` | Feature-gated | DR App Gateway frontend IP. |
| Edge | Application Gateway WAF | `agw-kairoai-prod-dr-si` | Feature-gated | Optional DR WAF. |
| Data | PostgreSQL Flexible Server | `psql-kairoai-prod-dr-si` | Feature-gated | Optional DR database/failover path. |
| Messaging | Service Bus namespace | `sb-kairoai-prod-dr-si` | Feature-gated | Optional active-passive messaging. |
| Secrets | Key Vault | `kv-kairoai-prod-dr-si` | Live | DR secrets/recovery. |
| AI | Azure AI Foundry / AI Services | `oai-kairoai-prod-dr-si` | Feature-gated | Optional DR AI endpoint. |
| Observability | Log Analytics | `law-kairoai-prod-dr-si` | Live | DR logs. |
| Observability | Application Insights | `appi-kairoai-prod-dr-si` | Live | DR telemetry. |
| Observability | Action group | `ag-kairoai-prod-dr-platform` | Live | DR alert routing. |
| Governance | Managed identities | `id-*` | Feature-gated | DR workload identities. |
| Governance | Azure Policy assignments | From `policy_assignments` | Feature-gated | DR scoped guardrails. |

### Application Services on AKS

| Service | Runtime Placement | Image Source | Primary Dependencies |
| --- | --- | --- | --- |
| `kairoai-dashboard` | AKS user node pool | Hub ACR | API Gateway, GitHub OAuth/App install flow. |
| `kairoai-api-gateway` | AKS user node pool | Hub ACR | Review orchestrator, auth/session config. |
| `kairoai-github-service` | AKS user node pool | Hub ACR | GitHub App credentials, GitHub API. |
| `kairoai-review-orchestrator` | AKS user node pool | Hub ACR | PostgreSQL, Service Bus, Terraform/security/cost/governance services. |
| `kairoai-terraform-runner` | AKS user node pool or private jobs subnet pattern | Hub ACR | Terraform CLI/workspace execution. |
| `kairoai-security-service` | AKS user node pool | Hub ACR | Checkov security scanning. |
| `kairoai-cost-service` | AKS user node pool | Hub ACR | Cost analysis engine. |
| `kairoai-governance-service` | AKS user node pool | Hub ACR | Policy/governance checks. |
| `kairoai-ai-service` | AKS user node pool | Hub ACR | Azure AI Foundry / Azure AI Services. |

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

Status: live for foundation and shared Front Door; firewall and bastion still deferred.

Creates:

- Hub resource group and VNet.
- Public DNS zone `kairoai.in`.
- Shared private DNS zones.
- ACR `acrkairoaihubci`.
- Hub Key Vault.
- Hub Log Analytics.
- Shared Azure Front Door global profile, endpoint, prod/test routes, DNS records, diagnostics, and alerts.

Remaining:

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

- Test application ingress host rules for `test.kairoai.in` and `test-api.kairoai.in`, if not already deployed.
- AGIC or ingress integration between AKS and App Gateway.
- Private endpoints for Key Vault, Service Bus, ACR, Monitor, and any remaining PaaS resources.
- Azure AI Foundry / AI Services deployment.
- Workload identities for each application service.
- Azure Policy baseline assignments.
- Diagnostic settings and alerts for App Gateway.
- Application deployment via Helm/Argo path.

Reason:

- Test is the proving ground for the complete platform before production.
- The full test path should validate `Front Door -> App Gateway WAF -> AKS -> services -> data/messaging/AI`.

### Wave 3 - Prod Primary

Status: applied and verified with a no-change plan.

Applied production foundation:

- `rg-kairoai-prod-ci`
- `vnet-kairoai-prod-ci`
- subnets for AKS system/user, App Gateway, private endpoints, PostgreSQL, private jobs.
- Hub-prod peering.
- Hub private DNS links.
- PostgreSQL Flexible Server.
- Key Vault.
- Service Bus.
- App Insights, Log Analytics or central workspace strategy.

Applied production runtime wave 1:

- AKS private cluster with autoscaled system and user pools.
- ACR pull permission from hub ACR.
- Key Vault CSI provider secret read permission.
- App Gateway WAF v2 with WAF policy, public IP, diagnostics, and edge alerts.
- Managed AGIC add-on connected to `agw-kairoai-prod-ci` with gateway-scoped Contributor access.
- Entra group `grp-kairoai-platform-admins` assigned AKS RBAC Cluster Admin for data-plane operations.
- Azure AI Services account `oai-kairoai-prod-si` with GPT-5.4 primary and GPT-5.4-mini fallback deployments.
- AI endpoint, account key, API version, and primary deployment name stored in production Key Vault.
- Shared hub Front Door routes for production apex/API hostnames.

Feature-gated for reviewed enablement:

- Azure Monitor workspace and Managed Grafana integration if prod-specific dashboards are required.
- Managed identities and federated credentials.
- Policy assignments.

Reason:

- Production should be a repeatable version of test with stronger security defaults, not a separately invented environment.

### Wave 4 - Prod DR

Status: applied and verified with a no-change plan.

Demo target: Level 2.

Applied Level 2 DR foundation:

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
| DNS | Public + private DNS live | Linked to hub private DNS | Live links | Live links |
| Network | Hub VNet live | Spoke VNet live | Live | Live |
| Peering | Hub-test live | Hub-test live | Live hub-prod | Live hub-prod-dr |
| ACR | Live shared ACR | Pulls from hub ACR | Pulls from hub ACR | Pulls from hub ACR |
| AKS | N/A | Live | Live | Optional Level 3 |
| App Gateway WAF | N/A | Live | Live | Optional Level 3 |
| Front Door | Live shared/global profile and DNS | Live shared test routes | Live shared prod routes | Planned failover route |
| PostgreSQL | N/A | Live | Live | Feature-gated DR database/failover |
| Service Bus | N/A | Live | Live | Feature-gated DR namespace |
| Key Vault | Live shared hub KV | Live | Live | Live recovery foundation |
| AI Foundry | N/A or shared future | Planned | Live in South India | Optional |
| Monitoring | Hub LAW live | LAW/AppI/AMW/Grafana live | LAW/AppI live | LAW/AppI live |
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
4. Added reusable App Gateway and Front Door diagnostics/alerts.
5. Added Azure Policy definition files and OPA/Conftest checks.
6. Ran a combined validation and saved-plan pass across all roots.

Saved plan status:

| Root | Saved plan | Create | Update | Delete | Notes |
| --- | --- | ---: | ---: | ---: | --- |
| `hub` | Latest plain plan | 0 | 0 | 0 | Shared Front Door, DNS, diagnostics, and alerts are applied and clean. |
| `test` | `test-full-architecture.tfplan` | 0 | 0 | 0 | Test observability is applied and clean. |
| `prod` | Latest plain plan | 0 | 0 | 0 | Production AKS, App Gateway WAF, and AI Services are applied and clean; shared edge is owned by hub. |
| `prod-dr` | `prod-dr-full-architecture.tfplan` | 0 | 0 | 0 | Level 2 DR foundation is applied and clean; warm runtime is gated off. |

## Immediate Next Implementation Step

1. Wait for Front Door custom domain `deploymentStatus` to complete for `kairoai.in`, `api.kairoai.in`, `test.kairoai.in`, and `test-api.kairoai.in`.
2. Probe `https://kairoai.in/health`, `https://api.kairoai.in/health`, `https://test.kairoai.in/health`, and `https://test-api.kairoai.in/health` through shared Front Door.
3. Wire Azure Policy definitions into assignment pipelines after test audit mode is confirmed.
4. Add private endpoints and tighten public network access once application connectivity is validated.

## Safety Rules

- Do not apply production until all environment plans are reviewed together.
- Keep App Gateway and Front Door enabled only where the target state is intentionally live.
- Never use `-var` to create a long-lived resource unless the committed defaults or tfvars are updated immediately after.
- Every apply must be followed by a plain `terraform plan` with no ad-hoc vars.
- Record each architecture-level decision in this file or `kairoai-platform/your-brain/decisions.md`.
