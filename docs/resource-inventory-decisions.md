# Resource Inventory and Decisions

Last updated: `2026-06-22 21:31:20 +05:30`

This file is the practical inventory for where KairoAI Azure resources live, why they exist, and whether they are live or planned. The high-level architecture remains in `azure-hub-spoke-blueprint.md`; this file is the operator-friendly companion.

## Subscription Layout

| Scope | Subscription | Subscription ID | Region | Purpose |
| --- | --- | --- | --- | --- |
| Hub | `kairoai-hub-subscription` | `5b942f88-17e6-4026-ae23-d520365fb916` | Central India | Shared platform services, central DNS, Terraform state, ACR, future Front Door/shared firewall controls. |
| Test spoke | `kairoai-test-subscription` | `6b01db76-626a-44a2-8119-17682410914a` | Central India | End-to-end test deployment for AKS, app runtime, App Gateway WAF, PostgreSQL, Service Bus, and observability. |
| Prod spoke | `kairoai-prod-subscription` | `a8270be7-dabc-4d92-98db-26a55025b0df` | Central India | Production primary workload deployment. |
| Prod DR | `kairoai-prod-subscription` | `a8270be7-dabc-4d92-98db-26a55025b0df` | South India | Production disaster-recovery resource group and regional failover components. |

## Hub Subscription Resources

| Resource | Name | Status | Reason |
| --- | --- | --- | --- |
| Terraform state RG | `rg-kairoai-tfstate-ci` | Live | Central place for remote state storage. |
| Terraform state storage | `stkairoaitfstateci` | Live | Stores `hubtfstate`, `testtfstate`, and `prodtfstate` containers. |
| Hub RG | `rg-kairoai-hub-ci` | Live | Shared hub resources live here. |
| Hub VNet | `vnet-kairoai-hub-ci` | Live | Central network that peers with spokes. |
| Public DNS zone | `kairoai.in` | Live | Azure DNS zone for app/domain records; GoDaddy can delegate to Azure nameservers. |
| Private DNS zones | Azure private DNS zones | Live | Shared private name resolution for PostgreSQL, ACR, Key Vault, Service Bus, Monitor, and Storage. |
| ACR | `acrkairoaihubci` | Live | Shared container registry for service images across environments. |
| Key Vault | `kv-kairoai-hub-ci` | Live | Shared hub secrets and future shared certificates. |
| Log Analytics | `law-kairoai-hub-ci` | Live | Hub logging workspace. |
| Front Door | `afd-kairoai-*-*` | Planned | Global entry point in the required path: Internet -> Front Door -> App Gateway WAF -> AKS. |
| Azure Firewall/Bastion | TBD by module plan | Planned/deferred | Centralized security/operations controls; deferred for cost and sequencing. |

## Test Subscription Resources

| Resource | Name | Status | Reason |
| --- | --- | --- | --- |
| Test RG | `rg-kairoai-test-ci` | Live | Single test spoke resource group. |
| Test VNet | `vnet-kairoai-test-ci` | Live | Isolated spoke VNet peered with hub. |
| AKS system subnet | `snet-aks-system` | Live | Dedicated subnet for AKS system node pool. |
| AKS user subnet | `snet-aks-user` | Live | Dedicated subnet for app workload nodes. |
| App Gateway subnet | `snet-app-gateway` | Live | Dedicated subnet required by Application Gateway WAF. |
| Private endpoints subnet | `snet-private-endpoints` | Live | Future private endpoints for platform services. |
| PostgreSQL delegated subnet | `snet-postgres-delegated` | Live | Required VNet-injected PostgreSQL Flexible Server subnet. |
| Test Key Vault | `kv-kairoai-test-ci` | Live | Test runtime secrets. |
| PostgreSQL Flexible Server | `psql-kairoai-test-ci` | Live | Application database; private networking enabled, public access disabled. |
| PostgreSQL database | `kairoai` | Live | App database. |
| Service Bus namespace | `sb-kairoai-test-ci` | Live | Async messaging for review jobs and analysis results. |
| Service Bus queues | `review-jobs`, `analysis-results` | Live | Application queue contracts. |
| Log Analytics | `law-kairoai-test-ci` | Live | Test logging. |
| Application Insights | `appi-kairoai-test-ci` | Live | App telemetry. |
| Azure Monitor workspace | `amw-kairoai-test-ci` | Live | Managed Prometheus metrics. |
| Managed Grafana | `amg-kairoai-test-ci` | Live | Dashboards and observability UI. |
| AKS | `aks-kairoai-test-ci` | Live | Test Kubernetes runtime. |
| AKS system pool | `system` | Live | Autoscaled `Standard_D2s_v4`, min `1`, max `2`. |
| AKS user pool | `user` | Live | Autoscaled `Standard_D2s_v4`, min `1`, max `3`. |
| App Gateway public IP | `pip-kairoai-test-ci` / `13.71.2.80` | Live | Public frontend IP for Application Gateway WAF. |
| Application Gateway WAF | `agw-kairoai-test-ci` | Live | Regional WAF and AKS ingress tier behind Front Door. |
| App Gateway WAF policy | `policy-agw-kairoai-test-ci` | Live | Standalone WAF policy required by current Azure Application Gateway WAF model. |
| Front Door | `afd-kairoai-test-ci` | Planned after App Gateway | Global entry point for `test.kairoai.in` and related routes. |
| Azure AI Foundry / AI Services | `oai-kairoai-test-ci` | Planned/feature-gated | AI explanation and recommendation service backend. |
| Managed identities | `id-*` | Planned/feature-gated | Workload identity and GitHub OIDC identities. |
| Azure Policy assignments | TBD | Planned/feature-gated | Security/compliance guardrails and future remediation assignments. |

## Prod and DR Subscription Resources

Production resources are not created yet. They will reuse the same module pattern validated in test.

| Scope | Planned Resources | Reason |
| --- | --- | --- |
| Prod primary | RG, VNet, AKS, App Gateway WAF, PostgreSQL Flexible Server, Key Vault, Service Bus, Monitor, Application Insights, managed identities, policy assignments, AI Foundry as needed | Production deployment in Central India. |
| Prod DR | DR RG, DR VNet, database recovery/failover path, Key Vault recovery, monitoring, optional warm standby AKS later | Demo target is DR Level 2 in South India. |

## Key Decisions

- Use reusable custom Terraform modules as the default because KairoAI needs explicit control over naming, hub-spoke networking, cross-subscription provider aliases, private DNS, RBAC, and cost gates.
- Use Azure Verified or community modules later only when they simplify standard resources without hiding important security behavior.
- Keep expensive edge resources feature-gated until reviewed in a saved Terraform plan.
- After App Gateway WAF is applied in test, keep `enable_app_gateway_waf = true` in the test root so normal Terraform plans do not destroy the live gateway.
- Use Azure Service Bus, not RabbitMQ, for Azure runtime messaging.
- Use Azure PostgreSQL Flexible Server, not a database pod.
- Use ACR in the hub subscription for images.
- Use AKS autoscaling from day one.
- Use `Standard_D2s_v4` for AKS node pools after Azure CLI SKU/quota checks showed B-series quota was unavailable in this subscription.
- Required ingress path is `Internet -> Azure Front Door -> Application Gateway WAF -> AKS`.
