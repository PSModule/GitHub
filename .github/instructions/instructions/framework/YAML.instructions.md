---
applyTo: '**/*.{yml,yaml}'
description: Framework-level YAML patterns covering workflows, actions, and shared configuration.
---

# Framework YAML Guidelines

Every PSModule YAML file—from GitHub workflows to documentation config—must remain readable, lintable, and secure across repositories.

## Goal
- Define universal YAML formatting, naming, and validation practices that keep automation predictable and diff-friendly.
- Outline GitHub Actions specific patterns so reusable actions and workflows share a common contract.

## Execution Steps
1. Confirm the file name follows lowercase-hyphenated conventions (e.g., `ci-build.yml`).
2. Apply formatting rules (UTF-8 + LF, two-space indent, single trailing newline) and organise sections logically.
3. Validate schema compatibility (yaml-language-server directive or dedicated validator) and resolve warnings.
4. For Actions/Workflows, ensure inputs, outputs, permissions, and branding align with PSModule expectations.
5. Re-run linting or workflow dry-runs after modifications to guarantee correctness.

## Behavior Rules
- **Formatting & Structure**
	- Use UTF-8 with LF endings, no tabs, two-space indentation, and keep lines ≤ 150 characters.
	- Group related keys, separate sections with a single blank line, and maintain metadata keys (`name`, `description`, etc.) first.
- **Naming & Organization**
	- Choose descriptive file names (`deployment-config.yml`, `mkdocs.yml`) and avoid generic labels.
	- Keep nesting shallow when possible; prefer flattened keys for clarity.
- **Scalars & Quoting**
	- Use plain scalars when safe and quote values that could be misinterpreted (`on`, `yes`, `007`, values starting with special characters).
	- Prefer double quotes; leverage `|` and `>` block styles intentionally to control wrapping.
- **Lists & Sequences**
	- Align dashes with the parent key indentation; use block lists for multi-line content and concise inline lists only for short sequences (< 80 chars).
- **Schemas & Validation**
	- Include `# yaml-language-server` schema hints when supported (GitHub workflow, Dependabot, etc.).
	- Treat schema or linter errors as blockers—update content or schema references instead of suppressing.
- **Comments**
	- Start comments with a space (`# Explanation`), keep them current, and format TODOs as `# TODO(owner): summary`.
- **Security & Secrets**
	- Never commit actual secrets; reference them via `${{ secrets.NAME }}` or other vault abstractions.
	- Redact examples with placeholders and pin external actions to specific versions.
- **GitHub Actions Patterns**
	- Supply metadata (name, description, author, branding) for composite actions and define explicit input/output contracts.
	- Structure repositories with `scripts/` and `tests/` folders, provide CI logging (`pwsh` with `Set-GitHubLogGroup`), and support Windows/Linux/macOS runners.
- **Workflows & Config**
	- Use descriptive workflow/job names, matrix strategies for multi-environment coverage, artifacts for cross-job data, and caching where beneficial.
	- Document options in accompanying README files and keep PSModule helper integrations consistent.

## Output Format
- YAML artifacts should lint cleanly, load under the documented schema, and, for workflows/actions, execute successfully in a dry run or targeted test.
- Action READMEs and repository docs must describe inputs/outputs exactly as defined in YAML.

## Error Handling
- If a conflicting third-party requirement forces deviation (e.g., different indentation), capture the reason in repo instructions and cite upstream constraints in comments.
- Fail fast on schema validation, permission mismatches, or unpinned external dependencies.

## Definitions
| Term | Description |
| --- | --- |
| **Composite action** | GitHub Action defined in YAML that orchestrates steps (often PowerShell) for reuse across repositories. |
| **Schema hint** | `yaml-language-server` directive that points editors to JSON schemas for validation and IntelliSense. |
| **Matrix strategy** | GitHub Actions feature allowing jobs to run across permutations of inputs (OS, PowerShell version, etc.). |
| **Pinned action** | External action referenced with a full version (`@v1.2.3` or commit SHA) to prevent supply-chain drift. |
