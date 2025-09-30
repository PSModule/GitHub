---
applyTo:
	- '**/action.yml'
	- '**/action.yaml'
description: Framework-level GitHub Actions definition patterns for PSModule composite actions.
---

# Framework GitHub Actions Guidelines

Composite actions standardize how PSModule scripts are packaged for reuse; this guidance keeps inputs, outputs, and branding consistent.

## Goal
- Provide a reusable action scaffold that integrates seamlessly with PSModule helpers and CI pipelines.
- Enforce naming, branding, and security patterns so actions remain trustworthy across repositories.

## Execution Steps
1. Start from the PSModule composite template below and adjust metadata (name, description, icon) to match the action’s purpose.
2. Define inputs/outputs with descriptive names, defaults, and documentation; ensure they map cleanly to environment variables.
3. Reference `PSModule/Install-PSModuleHelpers` (pinned version) before invoking repository scripts.
4. Add simulation steps or tests that verify the action works on Windows, Linux, and macOS runners.
5. Update accompanying README files with the same inputs/outputs and usage examples.

## Behavior Rules
- **Template Reference**

```yaml
name: ActionName (by PSModule)
description: Clear summary of the action’s purpose.
author: PSModule
branding:
	icon: package
	color: gray-dark

inputs:
	Name:
		description: Name of the resource to process.
		required: false
	WorkingDirectory:
		description: Directory in which the script runs.
		required: false
		default: '.'

outputs:
	OutputName:
		description: Description of the output.

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
- **Inputs & Outputs**
	- Use PascalCase input keys, provide defaults when safe, and mark required inputs sparingly.
	- Document outputs with structure details (type, example values) and consume `::set-output` alternatives (environment files) as required by GitHub updates.
- **Environment Variable Mapping**
	- Map each input to an environment variable named `PSMODULE_<ACTION>_INPUT_<Param>` to keep scripts consistent.
- **Branding & Naming**
	- Append “(by PSModule)” to action names, use `gray-dark` branding, and pick Feather icons matching purpose.
- **Dependencies & Scripts**
	- Pin helper and third-party actions to explicit versions; call scripts via `${{ github.action_path }}` to support relative resources.
- **Security**
	- Never embed secrets; expect callers to pass them via `${{ secrets.NAME }}` and validate inputs.
	- Restrict permissions in the consuming workflow (document recommended settings).

## Output Format
- Action metadata must parse via `act`/GitHub validators, include README documentation, and provide working sample workflows.
- Steps should emit structured logs suitable for CI grouping and set outputs using the GitHub environment file mechanism.

## Error Handling
- Fail the action with clear messages when required inputs are missing or operations error; bubble PowerShell exceptions with context.
- Document known limitations or platform restrictions in the README and TODO comments.

## Definitions
| Term | Description |
| --- | --- |
| **Composite action** | YAML-defined action bundling multiple steps for reuse. |
| **Environment file** | GitHub Actions mechanism for setting outputs, env vars, and path modifications (`$GITHUB_OUTPUT`, `$GITHUB_ENV`). |
| **Feather icon** | Icon set used for GitHub Action branding (`branding.icon`). |
