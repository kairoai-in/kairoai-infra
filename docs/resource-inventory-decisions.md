# Resource Inventory and Decisions

Last updated: `2026-06-23 13:45:00 +05:30`

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
| Public DNS zone | `kairoai.in` | Live | Azure DNS zone for app/domain records. GoDaddy is the registrar, but DNS is delegated to Azure nameservers: `ns1-05.azure-dns.com`, `ns2-05.azure-dns.net`, `ns3-05.azure-dns.org`, `ns4-05.azure-dns.info`. |
| Private DNS zones | Azure private DNS zones | Live | Shared private name resolution for PostgreSQL, ACR, Key Vault, Service Bus, Monitor, and Storage. |
| ACR | `acrkairoaihubci` | Live | Shared container registry for service images across environments. |
| Key Vault | `kv-kairoai-hub-ci` | Live | Shared hub secrets and future shared certificates. |
| Log Analytics | `law-kairoai-hub-ci` | Live | Hub logging workspace. |
| Front Door | `afd-kairoai-global` / `fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net` | Live for prod/test | Global entry point in the required path: Internet -> Azure DNS -> Front Door -> App Gateway WAF -> AKS. `afd-kairoai-global` is the Front Door profile; `fde-...azurefd.net` is the Azure-generated endpoint hostname used by DNS records. |
| Azure Firewall/Bastion | `afw-kairoai-hub-ci`, `afwp-kairoai-hub-ci`, `bas-kairoai-hub-ci` | Planned/deferred | Do not deploy now. Names and subnets are reserved, but Terraform does not currently deploy Firewall/Bastion resources. Deferred for cost and because centralized egress/private browser access are not required for the current demo. |

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

Production and prod-dr foundation resources are now created and verified with no-change Terraform plans. Production AKS, Application Gateway WAF, Front Door, AI Services, and Azure DNS records are live. Managed identities and policy assignments remain feature-gated.

| Scope | Planned Resources | Reason |
| --- | --- | --- |
| Prod primary | RG, VNet/subnets, hub peering, private DNS links, PostgreSQL Flexible Server, Key Vault, Service Bus, Monitor, Application Insights, AKS, App Gateway WAF, WAF policy, App Gateway diagnostics, Front Door, Azure DNS records, AI Services, and edge alerts are live; managed identities and policy assignments remain planned | Production deployment in Central India with high-cost runtime gates reviewed before apply. |
| Prod DR | DR RG, DR VNet/subnets, hub peering, private DNS links, Key Vault, monitoring are live; optional gated PostgreSQL, Service Bus, warm standby AKS, App Gateway WAF, AI Foundry, managed identities, and policy assignments remain planned | Demo target is DR Level 2 in South India, upgradeable without redesign. |

## Saved Architecture Plans

| Root | Plan File | Result |
| --- | --- | --- |
| `environments/hub` | `hub-full-architecture.tfplan` | `0` create, `0` update, `0` delete. |
| `environments/test` | `test-full-architecture.tfplan` | `0` create, `0` update, `0` delete. Test observability is applied and clean. |
| `environments/prod` | `prod-runtime-wave.tfplan` | `0` create, `0` update, `0` delete. Production AKS and App Gateway WAF are applied and clean. |
| `environments/prod-dr` | `prod-dr-full-architecture.tfplan` | `0` create, `0` update, `0` delete. Level 2 DR foundation is applied and clean. |

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
- Detailed public request flow is documented in `public-dns-and-ingress-flow.md`.
- Production Front Door routes use HTTP from Front Door to App Gateway for the first demo because App Gateway currently terminates only HTTP from AGIC-managed listeners; public TLS terminates at Front Door. End-to-end TLS to App Gateway is the next hardening step.
- Use Service Bus Premium capacity `1` and premium messaging partitions `1` for prod when Premium SKU is selected.
- Production runtime wave 1 is live: `aks-kairoai-prod-ci`, `agw-kairoai-prod-ci`, WAF policy, App Gateway public IP `20.219.35.127`, diagnostics, and edge alerts.
- Hub Key Vault is limited to shared control-plane certificates and automation references. Test and prod Key Vaults hold environment-specific runtime secrets to preserve isolation and limit blast radius.
- Managed AGIC is enabled on production AKS and receives Contributor only on `agw-kairoai-prod-ci`.
- Human AKS administration is granted through `grp-kairoai-platform-admins`, not through direct user role assignments.
- Service Bus retains `review-jobs` during migration and adds the application-contract queue `review-analysis`; workers use `review-analysis` and no live queue is deleted.
- Production runtime credentials use a queue-scoped `review-runtime` SAS rule with Send+Listen only; its connection string is stored in prod Key Vault as `service-bus-connection-string`.
- PostgreSQL modules generate the SQLAlchemy `postgresql+psycopg` URL internally and store it in each environment Key Vault as `database-url`; credentials are never committed to Helm values.
- Production AI Services runs in South India because it supports pay-as-you-go `GlobalStandard`. GPT-5.5 quota is zero for this subscription, so GPT-5.4 is the primary model with GPT-5.4-mini fallback at capacity 10 each.
- Key Vault private endpoints are added first while public network access remains enabled for safe rollout. After AKS Key Vault CSI mounts and Terraform secret management are validated from a private execution path, public network access can be disabled per Key Vault.
