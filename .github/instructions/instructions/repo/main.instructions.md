---
applyTo: '**/*'
description: Repository-specific instructions for the PSModule documentation site and supporting assets.
---

# PSModule Ecosystem Guidelines (Docs Repository)

This repository hosts the PSModule documentation site plus samples that illustrate module usage; instructions below extend the framework guidance with docs-specific context.

## Goal
- Clarify how this repo ties into the wider PSModule ecosystem (modules, actions, guidance) and what conventions it enforces.
- Highlight integration points (authentication helpers, logging, cross-repo dependencies) that documentation and samples must respect.

## Execution Steps
1. Determine whether your change touches documentation, samples, or automation assets, then load the matching framework + repo language instructions.
2. Maintain naming conventions for repositories, modules, and actions when referencing them in docs or scripts.
3. Reflect context-detection patterns in examples (local vs GitHub Actions vs enterprise) and keep authentication guidance accurate.
4. Update accompanying assets (MkDocs navigation, sample scripts, workflows) to stay synchronized.
5. Validate changes using the repository toolchain (MkDocs build, sample script execution, GitHub Actions dry-run) before finalizing.

## Behavior Rules
- **Ecosystem Components**
	- Document how PowerShell modules, GitHub Actions, MkDocs content, and tooling interoperate; keep examples current.
	- Emphasize PSModule build framework expectations, process orchestration, and release practices.
- **Context Awareness**
	- Describe how code detects execution environments (GitHub Actions vs local) and preserves existing authentication contexts using `GITHUB_*`/`PSMODULE_*` variables.
	- Cover both interactive and non-interactive usage patterns, especially for enterprise environments (GHES/GHEC).
- **Naming Conventions**
	- Reference repositories as `PSModule/ComponentName`, functions as `Verb-ModuleNoun`, classes as `ModuleObjectType`, and environment variables using `PSMODULE_COMPONENT_CATEGORY_Name`.
- **Development Workflows**
	- Promote standardized GitHub workflows, PSScriptAnalyzer, Pester coverage, and module initialization patterns used across PSModule projects.
- **Build & Release**
	- Document semantic versioning, automated releases, PowerShell Gallery publishing, changelog maintenance, and auto-generated docs.
- **Documentation Standards**
	- Keep MkDocs structure, working examples, troubleshooting sections, and references to PSModule.io up to date.
- **Error Handling & Logging**
	- Highlight actionable error messaging, GitHub API linkbacks, usage of `Get-PSCallStackPath`, `Set-GitHubLogGroup`, and secure logging practices.
- **Testing Strategy**
	- Emphasize integration tests spanning authentication modes, APIs, and negative scenarios with comprehensive CI reporting.

## Output Format
- Documentation updates should align with MkDocs navigation, include runnable examples, and explicitly reference supporting scripts or modules.
- Sample scripts must import and exercise PSModule components using current authentication/logging patterns.

## Error Handling
- Call out gaps or contradictions between framework and repo instructions in pull-request notes; resolve or document interim guidance before merge.
- If tooling (MkDocs, sample scripts) fails, treat it as blocking—fix or raise an issue before completion.

## Definitions
| Term | Description |
| --- | --- |
| **PSModule ecosystem** | Suite of PowerShell modules, GitHub Actions, documentation, and tooling maintained by the PSModule organization. |
| **Context detection** | Logic that adapts behavior based on environment variables or runtime indicators (local vs CI vs enterprise). |
| **Authentication abstraction** | Shared helpers that standardize connections across PAT, GitHub Apps, OAuth, or device flow. |
