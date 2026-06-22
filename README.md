# kairoai-infra

Azure Terraform infrastructure for KairoAI.

## Purpose

Provision Azure resources used by the KairoAI platform.

## Target Architecture

The target infrastructure is a multi-subscription Azure hub-spoke platform:

- Hub subscription: `5b942f88-17e6-4026-ae23-d520365fb916`.
- Test spoke subscription: `6b01db76-626a-44a2-8119-17682410914a`.
- Prod spoke subscription: `a8270be7-dabc-4d92-98db-26a55025b0df`.
- Primary region: Central India.
- DR region: South India.
- Public ingress: `Internet -> Azure Front Door -> Application Gateway WAF -> AKS`.

The detailed design is documented in `docs/azure-hub-spoke-blueprint.md`.

## Scope

- Resource groups.
- AKS.
- Azure Key Vault.
- Azure Container Registry.
- Azure Database for PostgreSQL Flexible Server.
- Azure Storage Account for Terraform remote state and future artifacts.
- Azure Monitor and Application Insights.
- Azure Service Bus for async application messaging.
- Managed identities and workload identity.
- Networking.
- Azure Front Door and Application Gateway WAF.
- Azure Firewall, Bastion, public/private DNS, and Terraform remote state.
- Azure AI Foundry/OpenAI resources.

## Database Direction

Hosted environments should use Azure Database for PostgreSQL Flexible Server.

PostgreSQL should not run as a pod in AKS for hosted environments. Local development can still use a PostgreSQL container.

## Async Work Direction

Application background work uses Azure Service Bus for hosted Azure environments.

## Structure

- `bootstrap/` - one-time remote state resources.
- `environments/hub/` - hub subscription root module.
- `environments/test/` - test spoke subscription root module.
- `environments/prod/` - production primary root module.
- `environments/prod-dr/` - production DR root module.
- `envs/dev/` - legacy early dev root module; keep untouched until migrated.
- `modules/` - reusable Azure Terraform modules.
- `docs/` - architecture and module interface docs.

## State

Terraform state should be stored in an Azure Storage Account backend. Bootstrap the backend first, then configure each environment to use a separate state key.

State keys:

- `kairoai/hub/terraform.tfstate`
- `kairoai/test/terraform.tfstate`
- `kairoai/prod/terraform.tfstate`
- `kairoai/prod-dr/terraform.tfstate`

## Current Status

Implementation is intentionally in planning/scaffold mode. Do not run Terraform apply until the hub-spoke blueprint is approved.
