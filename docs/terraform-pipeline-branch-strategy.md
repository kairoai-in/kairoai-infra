# Terraform Pipeline Branch Strategy

KairoAI keeps Terraform promotion separate from application CI/CD. Infrastructure uses one short-lived branch family and three protected target branches.

## Branches

| Target branch | Environment | Terraform directory | Apply label |
| --- | --- | --- | --- |
| `hub` | Shared hub | `environments/hub` | `apply-hub` |
| `test` | Test spoke | `environments/test` | `apply-test` |
| `main` | Production spoke | `environments/prod` | `apply-prod` |

Short-lived infrastructure work should use `azure/*` branches and open a pull request into the correct target branch.

## PR Pipeline

Workflow: `.github/workflows/terraform-pr.yml`

The PR pipeline is sequential and fail-fast:

1. `Terraform Format` runs `terraform fmt -check -recursive`.
2. `Terraform Validate` runs backend-free init and `terraform validate`.
3. `Terraform Security` runs Checkov against Terraform code in reporting mode while the current hardening backlog is being closed.
4. `Terraform Plan` logs into Azure with OIDC, initializes the real remote backend, and creates a plan.
5. `Terraform Policy` runs Conftest/OPA against the generated plan JSON.

If any stage fails, the Slack/email notification action sends a failure alert.

Checkov is intentionally `--soft-fail` during bootstrap because the current architecture still has known hardening work such as NSG associations, private endpoint enforcement, CMK encryption, local-auth disablement, and public-network lockdown. OPA remains the hard policy gate for the high-confidence KairoAI rules already agreed.

## Apply Pipeline

Workflow: `.github/workflows/terraform-apply.yml`

Apply runs only after all of these are true:

- The pull request was merged into `hub`, `test`, or `main`.
- The merged PR has the matching apply label: `apply-hub`, `apply-test`, or `apply-prod`.
- At least one approval exists on the pull request.
- Branch protection requires code owner review from `@kairoai-in/reviewer`.

The apply job still creates a fresh plan before applying, so the applied plan is based on the final merged branch state.

## Required GitHub Secrets

| Secret | Purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | Federated identity client ID for Terraform GitHub Actions. |
| `AZURE_TENANT_ID` | Tenant ID: `83474cb5-f1fa-4d06-906c-e5dad12ce3b9`. |
| `SLACK_INCOMING_WEBHOOK` | Slack notification webhook. |
| `SMTP_USERNAME` | Optional email notification username. |
| `SMTP_PASSWORD` | Optional email notification password. |
| `MAIL_FROM` | Optional email sender. |
| `MAIL_TO` | Optional email recipient. |

The federated Azure identity must have:

- Target subscription permissions for the selected environment.
- Hub state storage access for `rg-kairoai-tfstate-ci/stkairoaitfstateci`.
- Any cross-subscription read permissions required for hub/spoke remote state and peering.

## Review Model

The `reviewer` GitHub team owns the Terraform code through `.github/CODEOWNERS`. Branch protection requires one code owner review before merge. A pull request author generally cannot approve their own PR for required-review enforcement, so another reviewer should approve the change.

## GitHub Setup Status

Created/expected remote branches:

- `hub`
- `test`
- `main`

Required GitHub setup before this is fully enforced:

- Refresh GitHub CLI auth with `admin:org` before creating org teams: `gh auth refresh -h github.com -s admin:org`.
- Create `reviewer` and `dev` teams after the token has `admin:org`.
- Add `Elzabeth-L` and `ElzabethOps` to `reviewer`.
- Add the same users to `dev`.
- Enable branch protection/rulesets for `hub`, `test`, and `main`.

Current GitHub limitation observed during setup:

- GitHub rejected branch protection on the private infra repo with: `Upgrade to GitHub Pro or make this repository public to enable this feature.`
- Until that is resolved, the workflows still run, but GitHub will not enforce required status checks or code-owner review at the branch level.
