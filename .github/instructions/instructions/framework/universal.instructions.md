---
applyTo: '**/*'
description: Universal framework patterns for every PSModule repository.
---

# PSModule Framework Guidelines

These cross-language expectations keep every PSModule component consistent, pipeline-friendly, and ready for automation across local and CI environments.

## Goal
- Provide a single source of truth for ecosystem-wide authoring, organization, and integration requirements.
- Ensure code, docs, and automation remain portable between Windows PowerShell 5.1, PowerShell 7+, and GitHub Actions runners.

## Execution Steps
1. Map the change you are making to the relevant PSModule component (module code, docs, automation, etc.).
2. Review the framework behavior rules below and identify which ones influence your task.
3. Apply those rules while editing, validating encoding/line-endings and structural conventions before finalizing changes.
4. Confirm your update keeps PSModule tooling (Pester, MkDocs, GitHub Actions) functional by running targeted validations.
5. Document any notable deviations so repository instructions can extend or override these defaults if required.

## Behavior Rules
- **Architecture & Convention**
	- Favor modular design with single-responsibility components and semantic folders (`src/`, `tests/`, `docs/`).
	- Prefer convention over configuration to minimize bespoke setup.
	- Keep all deliverables cross-platform and context-aware; auto-detect CI/CD environments when possible.
- **Authoring Standards**
	- Encode files as UTF-8 with LF endings, no BOM unless a language-specific rule demands it.
	- Remove trailing whitespace, keep line length ≤ 150 characters, and end files with a single newline.
	- Write in English and use forward slashes (`/`) for paths.
- **Workflow Integration**
	- Develop and test PowerShell modules with `Import-Module ... -Force` and validate via `Invoke-Pester`.
	- Maintain semantic versioning and automated release flows through GitHub Actions.
	- Provide current documentation and ensure examples execute as written.
- **Error Handling & Resilience**
	- Prefer attribute-based validation (for example `[ValidateNotNullOrEmpty()]`) over manual checks.
	- Emit actionable error messages that link to resolution guidance when available.
	- Use standard PowerShell error surfaces (`throw`, `Write-Error`) while preserving pipeline semantics.
- **Ecosystem Integration**
	- Honour PSModule authentication abstractions and shared environment variables (`GITHUB_*`, `PSMODULE_*`).
	- Produce logs compatible with CI viewers (e.g., `LogGroup` sections) and consider cross-repo dependencies.

## Output Format
- Deliverables must retain the repository's semantic structure, respect encoding/line-ending rules, and include runnable examples or tests where prescribed.
- Documentation updates should remain MkDocs-compatible with intact navigation metadata.

## Error Handling
- When a rule cannot be satisfied (e.g., tooling limitation), document the deviation in repo-specific instructions and surface a warning in pull-request notes.
- Fail fast on structural violations (incorrect encoding, missing newline, or inconsistent naming) and correct them before submission.

## Definitions
| Term | Description |
| --- | --- |
| **PSModule ecosystem** | Collection of interoperable PowerShell modules, docs, and automation maintained under the PSModule banner. |
| **Pipeline-friendly** | Design that supports streaming input/output via the PowerShell pipeline without forcing array materialization. |
| **Context awareness** | Ability to detect execution environment (local PowerShell, GitHub Actions, enterprise runners) and adjust behavior automatically. |
| **LogGroup** | Structured logging helper used to create collapsible sections in CI/CD output. |
| **Semantic folders** | Conventional top-level directories (`src`, `tests`, `docs`, etc.) shared across PSModule repositories. |
