# Module Interface Plan

This file describes the first-pass module contracts before implementation.

## Common Inputs

All modules should accept:

- `name`
- `location`
- `resource_group_name`
- `tags`

Network-aware modules should also accept:

- `subnet_id`
- `private_dns_zone_ids`
- `private_endpoint_enabled`

Identity-aware modules should expose:

- `principal_id`
- `client_id`
- role assignment examples where needed

## Environment Roots

Root modules compose infrastructure in this order:

1. Naming locals.
2. Resource groups.
3. Networking.
4. Private DNS and peering.
5. Shared security controls.
6. Data services.
7. AKS and ingress.
8. Monitoring.
9. RBAC and policies.

## Apply Safety

Until CI/CD pipelines are added, every root module should be runnable with:

```powershell
terraform init
terraform validate
terraform plan
```

`terraform apply` requires explicit human approval and should start with hub bootstrap only.
