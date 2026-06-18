# Bootstrap

One-time Terraform used to create the remote state storage resources.

Expected resources:

- Resource group for Terraform state.
- Storage account.
- Blob container.

After bootstrap, environment root modules should use the Azure Storage backend.
