# OPA Policies

OPA/Conftest policies for Terraform plan checks.

## Terraform Plan Check

Generate a plan JSON and run Conftest:

```powershell
terraform plan -out tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json --policy policies/opa/terraform
```

The current guardrails focus on high-confidence platform rules:

- Production and DR Key Vaults must keep purge protection enabled.
- AKS node pools must use cluster autoscaler.
- Application Gateway must use WAF v2.
- Front Door must use Premium SKU.
- Service Bus must use Premium in production.
- Every managed resource should keep the standard KairoAI tags.
