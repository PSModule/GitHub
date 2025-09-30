---
applyTo: '**/functions/public/**/*.ps1'
description: Repository-specific PowerShell public function patterns for the GitHub module.
---

# GitHub Module Public Function Guidelines

These instructions refine public-facing cmdlets beyond the generic framework rules.

## Goal
- Ensure exported functions behave consistently for GitHub consumers, from context resolution to documentation.
- Provide a repeatable pattern for interacting with the GitHub API while remaining PSModule idiomatic.

## Execution Steps
1. Declare the function with `[CmdletBinding()]` and use `SupportsShouldProcess` only for state-changing operations (never on `Get-`).
2. Resolve and validate context in `begin {}` and capture permission comments (e.g., required scopes).
3. Design parameters with aliases (`Owner` alias `User`/`Organization`, `Repository` alias `Repo`) and defaults from context.
4. Invoke a single GitHub API endpoint via private helpers, handling both scalar and array results.
5. Update comment-based help with realistic examples, permissions, and `.LINK` references.

## Behavior Rules
- **Parameters & Aliases**
	- Support pipeline input (`ValueFromPipeline`, `ValueFromPipelineByPropertyName`) and throw descriptive errors when required context is absent.
- **Authentication Flow**

```powershell
begin {
		# Permissions: repo, admin:org
		$Context = Resolve-GitHubContext -Context $Context
		Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
}
```
- **API Integration**
	- Splat parameters into private helpers with consistent ordering (`Method`, `ApiEndpoint`, `Body`, `Context`).
	- Handle paging, arrays, and single objects gracefully; support GHES/GHEC base URLs.
- **Documentation**
	- Provide multiple examples referencing real PSModule repositories and include permission requirements in `.NOTES`.
	- Link to module documentation and the official GitHub API page via `.LINK` entries.
- **Error Handling**
	- Report rate limiting guidance, authentication failures per auth type, and include API links in error messages.

## Output Format
- Public functions must emit strongly typed objects, respect pipeline semantics, and expose complete help.

## Error Handling
- Treat missing context, permission failures, or mismatched outputs as blocking. Document temporary issues with TODO comments tied to work items.

## Definitions
| Term | Description |
| --- | --- |
| **SupportsShouldProcess** | Enabling `-WhatIf`/`-Confirm` for functions that modify GitHub state. |
| **Scope comment** | Inline comment listing required GitHub OAuth scopes or permissions for the API call. |
