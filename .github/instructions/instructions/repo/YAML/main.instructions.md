---
applyTo:
	- '**/*.yml'
	- '**/*.yaml'
description: Repository-specific YAML patterns for PSModule documentation samples, actions, and workflows.
---

# Repository YAML Guidelines

This repository ships reference workflows and composite actions that illustrate PSModule best practices. Use this guidance alongside the framework YAML files whenever you touch `.yml/.yaml` assets here.

## Goal
- Keep sample actions/workflows aligned with live PSModule automation while remaining easy to copy into consumer repos.
- Document environment variable mapping, secret usage, and branding conventions unique to PSModule actions.

## Execution Steps
1. Identify whether you are editing a composite action, reusable workflow, or documentation sample and load the relevant framework instruction file too.
2. Start from the PSModule templates below, adjusting names, inputs, and scripts to match the scenario.
3. Map every input to an environment variable using the PSModule naming convention; update PowerShell scripts accordingly.
4. Validate the workflow/action with `act` or GitHub dry-run triggers across Windows, Linux, and macOS when samples promise cross-platform support.
5. Update README/MkDocs pages that reference the YAML so documentation and code remain synchronized.

## Behavior Rules
- **Composite Actions**
	- Use the standard metadata structure and branding:

```yaml
name: ActionName (by PSModule)
description: Clear, actionable description.
author: PSModule
branding:
	icon: package
	color: gray-dark

inputs:
	Name:
		description: Name of the module/resource to process.
		required: false
	WorkingDirectory:
		description: Directory for script execution.
		required: false
		default: '.'

runs:
	using: composite
	steps:
		- name: Install PSModule helpers
			uses: PSModule/Install-PSModuleHelpers@v1

		- name: Execute action
			shell: pwsh
			working-directory: ${{ inputs.WorkingDirectory }}
			env:
				PSMODULE_ACTIONNAME_INPUT_Name: ${{ inputs.Name }}
			run: |
				& "${{ github.action_path }}/scripts/main.ps1"
```
- **Environment Variables**
	- Map inputs to env vars with `PSMODULE_<ACTION>_INPUT_<Param>` and mirror those names inside scripts.
- **Workflows & Samples**
	- Provide end-to-end flows (build, test, publish) that use PSModule actions such as `Initialize-PSModule`, `Build-PSModule`, `Test-PSModule`, and `Publish-PSModule`.
	- Demonstrate secrets management using `PSGALLERY_API_KEY`, OIDC tokens, or vault integrations.
- **Testing & Matrix Coverage**
	- Show matrix strategies across `ubuntu-latest`, `windows-latest`, and `macos-latest` when marketing cross-platform support.
	- Encourage running actions from `./` to validate composite definitions within the repo.
- **Release Automation**
	- Include workflow-dispatch samples with `version` inputs and `actions/create-release@v1` usage, emphasizing semantic version tags.
- **File Standards**
	- Maintain two-space indentation, single quotes unless interpolation is required, no trailing whitespace, and ≤150-character lines.

## Output Format
- YAML samples must pass GitHub workflow validation, align with documented secret names, and highlight PSModule-specific steps in comments.
- README/MkDocs snippets should match the actual files verbatim to avoid drift.

## Error Handling
- Treat mismatched input/env mappings, outdated action versions, or invalid branding metadata as blocking issues.
- If upstream changes force temporary deviations, document them inline and create follow-up tasks to restore the standard.

## Definitions
| Term | Description |
| --- | --- |
| **PSMODULE_ACTIONNAME_INPUT_* ** | Environment variable pattern used by PSModule scripts to consume composite action inputs. |
| **Reusable workflow** | Workflow called via `workflow_call` allowing other repositories to reuse PSModule automation. |
