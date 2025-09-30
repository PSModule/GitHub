---
applyTo: '.github/workflows/*.{yml,yaml}'
description: Repository-specific workflow patterns showcasing PSModule CI/CD automation.
---

# Repository Workflow Guidelines

The workflows in this repository demonstrate how consumers should orchestrate PSModule modules and actions.

## Goal
- Capture PSModule-specific conventions (run names, concurrency, secrets) that go beyond the generic framework guidance.
- Provide ready-to-adapt templates for `Process-PSModule` and other ecosystem workflows.

## Execution Steps
1. Start from `Process-PSModule.yml` (or relevant template) and adjust triggers, `run-name`, and permissions for the sample scenario.
2. Configure `.github/PSModule.yml` to control test coverage goals, module build matrices, and exclusions.
3. Reference shared secrets (`TEST_USER_PAT`, GitHub App credentials) as documented in `tests/README.md` for integration examples.
4. Validate workflows with `act` or PR dry-runs, confirming concurrency and permissions behave as expected.
5. Update documentation pages referencing the workflow when inputs, outputs, or secret usage changes.

## Behavior Rules
- **Structure & Naming**
	- Use descriptive `run-name` strings containing PR or branch context for audit clarity.
	- Define concurrency groups using `${{ github.workflow }}-${{ github.ref }}` and enable `cancel-in-progress` for efficiency.
- **Integration Pattern**
	- Prefer `uses: PSModule/Process-PSModule/.github/workflows/Process-PSModule.yml@v1` to reuse shared automation, supplying `ModuleName` and inheriting secrets.
	- Keep `.github/PSModule.yml` in sync with module expectations (coverage targets ≥ 50%, test exclusions, module variants).
- **Secrets & Auth**
	- Document secret names (`TEST_USER_PAT`, `TEST_APP_ORG_CLIENT_ID`, `TEST_APP_ORG_PRIVATE_KEY`, `PSGALLERY_API_KEY`) and require consumers to configure them.
	- Showcase OIDC usage by granting `id-token: write` only when necessary.
- **Testing Configuration**
	- Run PSModule actions across Windows, Linux, and macOS via matrices; highlight how to toggle scenarios with tags.
	- Include examples using the repository’s composite action directly (`uses: ./`).
- **Environment Integration**
	- Demonstrate use of `PSMODULE_*` variables, enterprise URL overrides, and context detection features.

## Output Format
- Workflows must run successfully in CI for sample branches, consume PSModule actions as documented, and emit structured logs/artifacts.
- README or docs should reference exact filenames and explain required secrets and environment expectations.

## Error Handling
- Treat missing secrets, permission errors, or mismatched module names as blocking; update instructions or templates accordingly.
- Capture known limitations (e.g., enterprise-specific adjustments) in comments with follow-up tracking.

## Definitions
| Term | Description |
| --- | --- |
| **Process-PSModule** | Shared reusable workflow that builds, tests, and publishes PSModule modules. |
| **PSModule configuration file** | `.github/PSModule.yml` controlling coverage thresholds, exclusions, and runner options. |
