---
applyTo: '**/*.{ps1,psm1,psd1}'
description: Framework-level PowerShell patterns governing function authoring and module layout.
---

# Framework PowerShell Guidelines

This file dives deeper into day-to-day function authoring, parameter design, and module implementation details for PSModule repositories.

## Goal
- Provide a repeatable blueprint for writing public and private functions that align with PSModule expectations.
- Ensure naming, help, pipeline behavior, and cross-platform execution are consistent across modules.

## Execution Steps
1. Before editing, confirm the function/module purpose and choose an approved verb-noun name.
2. Apply the formatting baseline (UTF-8 with BOM when 5.1 compatibility is needed, 4-space indentation, ≤150-character lines).
3. Flesh out parameters using validation attributes and pipeline support rules, then scaffold comment-based help.
4. Implement logic with appropriate pipeline sections (`begin/process/end`), error handling, and logging hooks.
5. Run linters (`Invoke-ScriptAnalyzer`), unit tests (Pester), and import the module (`Import-Module -Force`) to verify exports and behavior.

## Behavior Rules
- **Naming & Scope**
	- Use approved `Verb-Noun` cmdlet names (PascalCase) with unambiguous nouns; avoid abbreviations.
	- Parameters follow PascalCase; variables use PascalCase for module scope and camelCase for locals.
	- Avoid aliases unless required for backward compatibility, and document any that remain.
- **Formatting & Encoding**
	- Default to 4-space indentation, braces on the same line, and UTF-8 encoding (with BOM when Windows PowerShell 5.1 consumers demand it).
	- Trim trailing whitespace and close every file with a single newline.
- **Function Structure**
	- Start functions with `[CmdletBinding()]`, `[OutputType()]`, and comprehensive comment-based help.
	- Use the template below as a reference implementation:

```powershell
function Verb-Noun {
	<#!
	    .SYNOPSIS
	    Brief description.

	    .DESCRIPTION
	    Detailed description with context and usage.

	    .PARAMETER Parameter
	    Parameter description with context and examples.

	    .EXAMPLE
	    Verb-Noun -Parameter Value

	    Description of what this example demonstrates.

	    .OUTPUTS
	    [OutputType] - Description of output object properties.

	    .NOTES
	    Additional context or usage notes.
	#>
	[OutputType([ExpectedType])]
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Parameter
	)

	begin {
		$stackPath = Get-PSCallStackPath
		Write-Debug "[$stackPath] - Start"
	}

	process {
		try {
			# Implementation
		} catch {
			Write-Debug "Error: $_"
			throw
		}
	}

	end {
		Write-Debug "[$stackPath] - End"
	}
}
```

- **Parameter Design**
	- Prefer `[switch]` for flags, leverage validation attributes, and support pipeline binding when natural.
	- Minimize mandatory parameters when context detection can supply defaults.
	- Example pattern:

```powershell
function Set-ResourceConfiguration {
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory)]
		[string]$Name,
		[ValidateSet('Dev', 'Test', 'Prod')]
		[string]$Environment = 'Dev',
		[switch]$Force,
		[ValidateNotNullOrEmpty()]
		[string[]]$Tags
	)
	process { }
}
```
- **Pipeline & Output**
	- Stream items through `process {}` without accumulating arrays; emit objects, not formatted strings.
	- Provide `-PassThru` on action cmdlets when returning modified objects adds value.
- **Error Handling & Logging**
	- Use `SupportsShouldProcess`/`ShouldProcess` for state changes and choose appropriate `ConfirmImpact`.
	- Catch specific exceptions, rethrow with context, and leverage `Write-Error` for per-item failures.
	- Integrate PSModule logging helpers (e.g., `Set-GitHubLogGroup`) when running in CI.
- **Help & Documentation**
	- Include `.LINK` entries for external docs, ensure examples are runnable, and keep help synchronized with parameter definitions.
- **Cross-Platform & Performance**
	- Use forward slashes in paths, test on Windows PowerShell 5.1 and PowerShell 7+, and minimize per-iteration allocations.
	- Favor splatting and efficient cmdlets (`ForEach-Object -Parallel` only when concurrency justified).
- **Security**
	- Handle secrets with `SecureString` or other secure abstractions, validate inputs thoroughly, and respect least privilege when calling external services.

## Output Format
- PowerShell artifacts must import cleanly, expose accurate help via `Get-Help`, pass analyzer rules, and integrate with Pester suites defined for the module.
- Public functions should remain discoverable through module manifests and respect semantic versioning commitments.

## Error Handling
- Treat analyzer violations, failed imports, or broken pipeline behavior as blocking; resolve or document remediation steps before merge.
- If legacy constraints require bending a rule, annotate the rationale with TODO/follow-up and capture it in repo instructions.

## Definitions
| Term | Description |
| --- | --- |
| **Approved verbs** | List returned by `Get-Verb` denoting sanctioned PowerShell verb choices. |
| **Comment-based help** | Inline documentation that feeds `Get-Help`, covering synopsis, description, parameters, examples, outputs, and notes. |
| **SupportsShouldProcess** | CmdletBinding capability enabling `-WhatIf`/`-Confirm` support for potentially destructive operations. |
| **Splatting** | Technique of passing parameter dictionaries (`@{}`) to cmdlets for readability and reuse. |
