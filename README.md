# kairoai-infra

Azure Terraform infrastructure for KairoAI.

## Purpose

Provision Azure resources used by the KairoAI platform.

## Scope

- Resource groups.
- AKS.
- Azure Key Vault.
- Azure Container Registry.
- Azure Database for PostgreSQL Flexible Server.
- Azure Storage Account for Terraform remote state and future artifacts.
- Azure Monitor and Application Insights.
- RabbitMQ infrastructure path, if we choose managed broker resources later.
- Managed identities and workload identity.
- Networking.

## Database Direction

Hosted environments should use Azure Database for PostgreSQL Flexible Server.

PostgreSQL should not run as a pod in AKS for hosted environments. Local development can still use a PostgreSQL container.

## Async Work Direction

Application background work uses RabbitMQ with Celery.

For early hosted environments, RabbitMQ may run in AKS through the deployment repo. If we later choose a managed RabbitMQ-compatible broker, this repo will provision the required Azure/network resources.

## Structure

- `bootstrap/` - one-time remote state resources.
- `envs/dev/` - dev environment root module.
- `envs/staging/` - staging environment root module.
- `envs/prod/` - production environment root module.
- `modules/` - reusable Azure Terraform modules.

## State

Terraform state should be stored in an Azure Storage Account backend. Bootstrap the backend first, then configure each environment to use a separate state key.
