# Private Endpoint Module

Reusable private endpoint module for Azure PaaS resources.

Initial use:

- Key Vault private endpoints with `subresource_names = ["vault"]`.
- Private DNS zone group attached to `privatelink.vaultcore.azure.net`.

Rollout safety:

- Create private endpoints before disabling public network access.
- Validate AKS/CSI and Terraform secret access through private DNS.
- Disable public network access only after the private execution path is proven.
