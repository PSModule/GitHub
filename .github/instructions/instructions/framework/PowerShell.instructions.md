---
applyTo:
	- '**/*.ps1'
	- '**/*.psm1'
	- '**/*.psd1'
description: Framework-level PowerShell patterns that every PSModule repository must follow.
---

# Framework PowerShell Guidelines

These rules define the baseline for all PowerShell authored within the PSModule ecosystem, regardless of repository or module specialization.

## Goal
- Establish consistent formatting, help, and module architecture expectations for every PowerShell source file.
- Ensure code remains portable between Windows PowerShell 5.1, PowerShell 7+, and GitHub-hosted runners.

## Execution Steps
1. Identify the PowerShell artifact you are modifying (function, script, module manifest, etc.).
2. Apply the formatting and naming rules listed below before committing.
3. Confirm comment-based help and error handling align with the guidance.
4. Run PSScriptAnalyzer (or repository equivalent) and address violations.
5. Validate module load by importing with `Import-Module -Force` in both Windows PowerShell 5.1 (when available) and PowerShell 7+.

## Behavior Rules
- **Formatting & Encoding**
	- Use UTF-8 with LF endings; trim trailing whitespace and limit lines to 150 characters.
	- End each file with a single newline and avoid tabs (4-space indentation unless a repo override states otherwise).
- **Comment-Based Help**
	- Provide full help for all public functions, including `.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`, parameter entries, and `.LINK` references where applicable.
	- Keep examples executable and reflective of supported scenarios.
- **Error Handling**
	- Use consistent terminating/non-terminating patterns, preferring `[ValidateNotNullOrEmpty()]` and other attributes for upfront validation.
	- Emit actionable guidance and documentation links in error messages.
- **Code Quality**
	- Enforce approved PowerShell verbs, strong typing, and clear parameter naming (PascalCase).
	- Suppress analyzer violations only with justification and scope them narrowly.
- **Module Architecture**
	- Separate public and private functions; structure modules into semantic folders.
	- Utilize classes for complex data structures and ensure module initialization handles both 5.1 and 7+ environments.
- **Pipeline & Performance**
	- Support streaming via `begin/process/end` blocks; avoid unnecessary array accumulation.
	- Minimize per-iteration allocations and favor efficient idioms (splatting, implicit output).
- **Security**
	- Protect credentials (SecureString where appropriate) and validate inputs rigorously.
	- Follow least-privilege principles when invoking external services or modifying system state.

## Output Format
- PowerShell files should import without errors, expose help accessible via `Get-Help`, and pass analyzer/test suites defined in the repository.
- Refactors must preserve module manifests, exported members, and formatting conventions.

## Error Handling
- If a rule must be relaxed (e.g., due to legacy compatibility), document the exception in repo-specific instructions and annotate the source with justification comments.
- Treat analyzer or import failures as blocking issues; resolve before final hand-off.

## Definitions
| Term | Description |
| --- | --- |
| **PSScriptAnalyzer** | Static analysis tool used to enforce PowerShell coding standards in PSModule projects. |
| **Comment-based help** | Inline documentation block that powers `Get-Help` output for functions and scripts. |
| **SupportsShouldProcess** | Cmdlet binding feature enabling `-WhatIf`/`-Confirm` semantics for destructive actions. |
| **Pipeline-supporting function** | A function that accepts input via `ValueFromPipeline` and processes items in the `process {}` block without array buffering. |
