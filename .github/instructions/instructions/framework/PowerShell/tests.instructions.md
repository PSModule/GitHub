---
applyTo: '**/*.Tests.ps1,**/tests/**/*.ps1'
description: Framework-level PowerShell test patterns using Pester.
---

# Framework PowerShell Testing Guidelines

Use this when writing Pester tests for PSModule modules—consistent structure keeps suites predictable and CI-friendly.

## Goal
- Standardize test organization, naming, and setup so suites mirror production code structure.
- Ensure tests cover both happy paths and failure scenarios across local and GitHub Actions environments.

## Execution Steps
1. Create or update a `.Tests.ps1` file that mirrors the source path (e.g., `src/functions/Public/Get-Item.ps1` → `tests/functions/Public/Get-Item.Tests.ps1`).
2. Scaffold `Describe`/`Context` blocks capturing functionality and scenario boundaries.
3. Implement Arrange-Act-Assert using the template below, adding setup/cleanup hooks as required.
4. Exercise different authentication or runtime contexts (local vs GitHub Actions) when relevant.
5. Run `Invoke-Pester` locally (and optionally in PowerShell 5.1 + 7+) to confirm the suite passes before committing.

## Behavior Rules
- **Structure**
	- Keep one primary `Describe` per function or feature and use `Context` blocks for scenario variations.
	- Store test data at the top-level or within `BeforeAll`; clean up with `AfterAll/AfterEach`.
- **Template Reference**
	- Base suites on this skeleton:

```powershell
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

BeforeDiscovery {
		# Discovery-time setup (mock data, environment checks)
}

Describe 'Module-Function Tests' {
		BeforeAll {
				$testData = @{
						Parameter1 = 'TestValue'
						Parameter2 = 42
				}
		}

		Context 'When function is called with valid parameters' {
				It 'Should return expected result' {
						$result = Module-Function -Parameter $testData.Parameter1
						$result | Should -Be 'Expected'
				}
		}

		Context 'When function is called with invalid parameters' {
				It 'Should throw appropriate error' {
						{ Module-Function -Parameter $null } | Should -Throw
				}
		}
}
```
- **Assertions**
	- Use precise assertions (`Should -Be`, `-Match`, `-Throw`), covering positive, negative, and pipeline behaviors.
	- Validate error messages or types when they matter for consumers.
- **Context Awareness**
	- Simulate GitHub Actions runs (matrix combinations, environment variables, secrets) as part of tests when feasible.
	- Use `Set-GitHubLogGroup` or equivalent logging helpers to keep CI output structured.
- **Performance & Integration**
	- Benchmark critical paths (e.g., repeated API calls) and include smoke tests for module import/export.
	- Exercise cross-function flows and real API interactions in dedicated integration suites, gating them with tags if slow.

## Output Format
- Test suites must pass under `Invoke-Pester`, generate NUnit/XML reports when CI expects them, and respect naming conventions so dashboards categorize results correctly.
- Document required environment variables or secrets in accompanying README/test docs.

## Error Handling
- Treat failing assertions, leaked resources, or missing cleanup as blockers; fix before merge.
- If a scenario cannot be automated, document manual validation steps and track automation backlog items.

## Definitions
| Term | Description |
| --- | --- |
| **Arrange-Act-Assert** | Canonical testing pattern for structuring setup, execution, and verification. |
| **BeforeDiscovery** | Pester hook executed during discovery phase, useful for locating data or skipping suites. |
| **Tagging** | Mechanism to categorize tests (e.g., `-Tag Integration`) for selective execution. |
