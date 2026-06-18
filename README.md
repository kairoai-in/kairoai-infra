# kairoai-infra

Azure Terraform infrastructure for KairoAI.

## Purpose

Provision Azure resources used by the KairoAI platform.

## Scope

- Resource groups.
- AKS.
- Azure Key Vault.
- Azure Container Registry.
- Azure Database for PostgreSQL.
- Azure Storage Account for Terraform remote state and future artifacts.
- Azure Monitor and Application Insights.
- Managed identities and workload identity.
- Networking.

## Structure

- `bootstrap/` - one-time remote state resources.
- `envs/dev/` - dev environment root module.
- `envs/staging/` - staging environment root module.
- `envs/prod/` - production environment root module.
- `modules/` - reusable Azure Terraform modules.

## State

Terraform state should be stored in an Azure Storage Account backend. Bootstrap the backend first, then configure each environment to use a separate state key.
