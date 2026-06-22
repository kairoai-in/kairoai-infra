# Azure Policy

Custom policy definitions and initiatives for KairoAI infrastructure governance.

These policy definitions are stored as source-controlled guardrails first. They can be assigned through the reusable `modules/policy` module after we confirm the assignment scope and remediation identity strategy.

## Definitions

| File | Purpose |
| --- | --- |
| `require-standard-tags.json` | Audits resources missing required KairoAI tags. |
| `deny-public-paas-network.json` | Denies public network access for supported PaaS resources after private endpoint hardening is ready. |
| `initiative-kairoai-baseline.json` | Groups the KairoAI baseline policies into one initiative definition. |

## Assignment Strategy

Start with `Audit` effects in test, then move to `Deny` in prod after the app path is stable. Remediation-capable assignments should use a managed identity and least-privilege role assignments at resource-group scope.
