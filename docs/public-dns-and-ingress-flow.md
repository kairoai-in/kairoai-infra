# Public DNS and Ingress Flow

Last updated: `2026-06-26 00:00:00 +05:30`

This document explains what happens when a user opens `https://kairoai.in` and how GoDaddy, Azure DNS, Azure Front Door, Application Gateway WAF, and AKS fit together.

## Short Version

```text
User browser
  -> kairoai.in
  -> GoDaddy registrar delegation
  -> Azure DNS authoritative nameservers
  -> Azure DNS zone kairoai.in in hub subscription
  -> Azure Front Door endpoint fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
  -> Azure Front Door profile afd-kairoai-global
  -> prod/test Application Gateway WAF
  -> AKS ingress managed by AGIC
  -> KairoAI services
```

## Nameserver Delegation

`kairoai.in` is registered at GoDaddy, but GoDaddy is not managing the DNS records anymore when custom nameservers are enabled.

GoDaddy points the domain to Azure DNS using these authoritative nameservers:

```text
ns1-05.azure-dns.com.
ns2-05.azure-dns.net.
ns3-05.azure-dns.org.
ns4-05.azure-dns.info.
```

This means:

- GoDaddy remains the domain registrar.
- Azure DNS becomes the authoritative DNS host for `kairoai.in`.
- DNS records such as `@`, `api`, `test`, and `test-api` should be managed in the Azure DNS zone, not in GoDaddy.

## Full Browser Request Flow

1. The user enters `https://kairoai.in`.
2. The browser asks DNS resolvers for `kairoai.in`.
3. The `.in` registry sees that GoDaddy is the registrar.
4. GoDaddy returns the delegated Azure DNS nameservers.
5. The resolver asks Azure DNS for the record in the `kairoai.in` public DNS zone.
6. Azure DNS returns the Front Door target:
   - Apex/root `kairoai.in` uses an Azure DNS alias `A` record to the Front Door endpoint resource.
   - Subdomains such as `api.kairoai.in`, `test.kairoai.in`, and `test-api.kairoai.in` use `CNAME` records to the Front Door endpoint hostname.
7. The browser connects to Azure Front Door at the global edge.
8. Azure Front Door terminates public TLS for the custom hostname.
9. Front Door selects a route based on the hostname:
   - `kairoai.in` -> prod dashboard route.
   - `api.kairoai.in` -> prod API route.
   - `test.kairoai.in` -> test dashboard route.
   - `test-api.kairoai.in` -> test API route.
10. Front Door forwards the request to the correct Application Gateway WAF origin.
11. Application Gateway WAF evaluates regional WAF rules.
12. Application Gateway routes to AKS ingress rules managed by AGIC.
13. AKS routes traffic to the correct KairoAI service.

## Front Door Names

Two names appear in Azure:

| Name | Meaning |
| --- | --- |
| `afd-kairoai-global` | Azure Front Door profile resource name. This is the shared global edge service. |
| `fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net` | Azure-generated Front Door endpoint hostname. DNS records point to this endpoint so custom domains can use Front Door. |

The `fde-...azurefd.net` hostname is not the user-facing brand domain. It is the Azure endpoint behind the custom domains.

## DNS Records in Architecture

Represent DNS records like this:

```text
Azure DNS zone: kairoai.in
  @             A/ALIAS -> Front Door endpoint resource
  api           CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
  test          CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
  test-api      CNAME   -> fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net
  _dnsauth*     TXT     -> Front Door managed certificate validation tokens
```

## Current Route Mapping

```text
kairoai.in
  -> Azure Front Door route: prod dashboard
  -> prod Application Gateway WAF
  -> prod AKS dashboard service

api.kairoai.in
  -> Azure Front Door route: prod API
  -> prod Application Gateway WAF
  -> prod AKS API gateway service

test.kairoai.in
  -> Azure Front Door route: test dashboard
  -> test Application Gateway WAF
  -> test AKS dashboard service

test-api.kairoai.in
  -> Azure Front Door route: test API
  -> test Application Gateway WAF
  -> test AKS API gateway service
```

## Diagram Notes

When drawing the architecture:

- Draw GoDaddy outside Azure as the registrar only.
- Draw Azure DNS inside the hub subscription as the authoritative DNS host.
- Draw `afd-kairoai-global` in the hub subscription as the shared global edge.
- Label the Front Door endpoint hostname as `fde-kairoai-global-abbxdsduhdbbe5dy.z02.azurefd.net`.
- Draw separate Front Door routes for prod and test hostnames.
- Draw prod/test Application Gateway WAFs inside their spoke subscriptions.
- Draw AKS behind each App Gateway.

## Firewall and Bastion Status

Do not deploy Azure Firewall or Azure Bastion right now.

They are intentionally deferred, not forgotten:

- Terraform reserves hub subnet names and CIDRs for them.
- Terraform keeps approved names for them in locals.
- The Firewall module currently exists only as a placeholder.
- No `azurerm_firewall`, `azurerm_firewall_policy`, or `azurerm_bastion_host` resource is currently deployed.

Reason:

- Firewall and Bastion add meaningful monthly cost.
- The current demo path does not require browser-based private SSH/RDP through Bastion.
- Centralized egress inspection through Azure Firewall should be added only after route tables, private endpoints, and egress policy are finalized.

