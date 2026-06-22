# Bootstrap

One-time Terraform used to create the remote state storage resources.

Expected resources:

- Resource group for Terraform state.
- Storage account.
- Blob container.

After bootstrap, environment root modules should use the Azure Storage backend.

## Planned Defaults

- Subscription: hub subscription `5b942f88-17e6-4026-ae23-d520365fb916`.
- Region: Central India.
- Storage replication: ZRS.
- Blob versioning: enabled.
- Blob/container soft delete: 30 days.
- Public network access: enabled only for bootstrap, then disabled after private endpoint access is ready.

## Example

```powershell
terraform init
terraform plan `
  -var="resource_group_name=rg-kairoai-tfstate-ci" `
  -var="storage_account_name=stkairoaitfstateci" `
  -var="container_name=tfstate"
```
