# Terraform State Bootstrap Plan

Terraform state will live in the hub subscription.

## Target

- Subscription: `kairoai-hub-subscription`
- Subscription ID: `5b942f88-17e6-4026-ae23-d520365fb916`
- Tenant ID: `83474cb5-f1fa-4d06-906c-e5dad12ce3b9`
- Region: Central India
- Resource group: `rg-kairoai-tfstate-ci`
- Storage account: `stkairoaitfstateci`
- Containers:
  - `hubtfstate`
  - `testtfstate`
  - `prodtfstate`

## State Keys

- `hubtfstate/kairoai/hub/terraform.tfstate`
- `hubtfstate/kairoai/bootstrap/terraform.tfstate`
- `testtfstate/kairoai/test/terraform.tfstate`
- `prodtfstate/kairoai/prod/terraform.tfstate`
- `prodtfstate/kairoai/prod-dr/terraform.tfstate`

## Bootstrap Flow

1. Run `terraform init` inside `bootstrap/`.
2. Run `terraform plan` with state resource names.
3. Review plan manually.
4. Run `terraform apply` only after approval.
5. Configure `bootstrap/backend.tf` and run `terraform init -migrate-state` so bootstrap state is remote too.
6. Copy `backend.tf.example` to `backend.tf` in each environment after the storage account exists.
7. Run `terraform init -migrate-state` only if migrating local state later.

## Hardening After Bootstrap

- Add private endpoint for blob storage.
- Link `privatelink.blob.core.windows.net` to required VNets.
- Disable public network access after CI/private connectivity path is available.
- Use RBAC and avoid broad storage account key access for users.
- Keep blob versioning and delete retention enabled.
- Bootstrap grants Storage Blob Data Contributor to the Terraform principal and any explicitly supplied additional principal IDs.

## Safety

No CI/CD apply pipeline should be added until the bootstrap path has been validated manually.
