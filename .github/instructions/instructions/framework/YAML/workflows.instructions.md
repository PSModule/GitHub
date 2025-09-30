---
applyTo:
	- '**/.github/workflows/*.yml'
	- '**/.github/workflows/*.yaml'
description: Framework-level GitHub workflow patterns for CI/CD.
---

# Framework GitHub Workflows Guidelines

Workflows orchestrate PSModule automation; keeping them consistent ensures reliable CI/CD across repositories.

## Goal
- Provide a canonical workflow skeleton, key ordering, and permission strategy.
- Balance robustness, security, and performance for GitHub-hosted and self-hosted runners.

## Execution Steps
1. Base new workflows on the template below, adjusting triggers, permissions, and concurrency to fit the scenario.
2. Define jobs with descriptive names, `needs` dependencies, and matrix strategies where cross-platform coverage is required.
3. Use pinned action versions, PSModule helpers, and scripts stored in `.github/scripts` for multi-line logic.
4. Tune caching, artifacts, and secrets management for the workload.
5. Test via `act` or selective dispatch events before merging, monitoring logs for unexpected warnings.

## Behavior Rules
- **Template Reference**

```yaml
name: Workflow Name
on:
	push:
		branches: [main]
	pull_request:
		branches: [main]
	workflow_dispatch:

permissions:
	contents: read

concurrency:
	group: ${{ github.workflow }}-${{ github.ref }}
	cancel-in-progress: true

jobs:
	job-name:
		name: Job Display Name
		runs-on: ubuntu-latest
		steps:
			- name: Checkout
				uses: actions/checkout@v4

			- name: Setup PowerShell
				uses: PSModule/Setup-PowerShell@v1

			- name: Execute Action
				uses: PSModule/ActionName@v1
```
- **Key Ordering & Structure**
	- Order top-level keys as `name`, `on`, `permissions`, `env`, `defaults`, `concurrency`, `jobs`; separate sections with single blank lines.
- **Permissions & Security**
	- Grant least privilege (read-only by default); escalate at job level when necessary and document justification.
	- Never output secrets; rely on `${{ secrets.NAME }}` or OIDC tokens for external auth.
- **Scripts & Steps**
	- Keep inline scripts short; move longer logic to `.github/scripts` and reference with `run: pwsh` and path.
	- Pin all third-party actions to versions/tags (avoid `@main`).
- **Job Design**
	- Use `needs` for ordering, matrices for OS/PowerShell coverage, and descriptive `name` values for readability.
	- Incorporate caching (PowerShell modules, npm/pip dependencies) and artifact handling with explicit retention.
- **Error Handling & Resilience**
	- Avoid `continue-on-error` except for non-blocking tasks; include cleanup steps and actionable failure messages.
- **Performance**
	- Cancel superseded runs via concurrency, minimize redundant jobs, and leverage parallelization judiciously to control usage.
- **PSModule Integration**
	- Use PSModule helper actions consistently, align logging (`Set-GitHubLogGroup`), and ensure modules import with required versions.

## Output Format
- Workflows must pass YAML validation, run successfully on target runners, and emit structured logs/artifacts consumable by maintainers.
- Document triggers, environment assumptions, and required secrets in repository README or `.github/workflows/README.md`.

## Error Handling
- Treat failed steps as blocking unless explicitly non-critical; surface failure causes clearly (e.g., `Write-Error` with guidance in PowerShell steps).
- For flaky upstream services, add retries with exponential backoff and log references to tracking issues.

## Definitions
| Term | Description |
| --- | --- |
| **Concurrency group** | GitHub Actions feature preventing overlapping runs based on workflow/ref keys. |
| **Matrix** | Job expansion technique for running the same steps across environments. |
| **OIDC token** | OpenID Connect token issued by GitHub for requesting cloud credentials without stored secrets. |
