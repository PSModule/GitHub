---
applyTo: '**/src/functions/public/**/*.ps1'
description: Public PowerShell function standards for PSModule modules.
---

# Public Function Guidelines

Public functions form the GitHub module’s external API; follow these rules to keep behaviors predictable.

## Goal
- Provide a consistent surface area for consumers interacting with GitHub resources via PSModule.
- Guarantee every exported cmdlet supports context resolution, authentication, and pipeline conventions.

## Execution Steps
1. Place the function under `src/functions/public/<ObjectType>/` and mirror tests in `tests/<ObjectType>/`.
2. Name the function using an approved verb and GitHub noun (`Get-GitHubRepository`).
3. Start the function with context resolution and validation (`Resolve-GitHubContext`, `Assert-GitHubContext`).
4. Implement business logic using private helpers, returning strongly typed objects.
5. Write comment-based help, update `[OutputType()]`, and add/refresh tests.

## Behavior Rules
- **Naming & Scope**
	- Group functions by GitHub entity; keep each function focused on a single API endpoint or action.
- **Authentication & Context**
	- Support PAT, OAuth, GitHub App, and installation tokens; pass resolved `[GitHubContext]` to private helpers.
- **Help Documentation**
	- Include `.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`, `.INPUTS`, `.OUTPUTS`, `.LINK` sections referencing PSModule docs.
- **Pipeline Support**
	- Use `ValueFromPipeline`/`ValueFromPipelineByPropertyName`, handle single items and arrays, and return typed objects for chaining.
- **Parameter Design**
	- Favor object-oriented names (`Owner`, `Repository`), leverage parameter sets, and apply validation attributes.
- **Output Types**
	- Decorate with `[OutputType()]`, return classes like `[GitHubRepository]`, and ensure formatting/serialization support.

## Output Format
- Each public function must import with the module, expose updated help (`Get-Help`), and emit strongly typed results consumable by downstream cmdlets.

## Error Handling
- Raise clear errors when context or required parameters are missing and include links to relevant docs/API references.
- Document temporary deviations (e.g., pending API coverage) with TODO comments referencing issues.

## Definitions
| Term | Description |
| --- | --- |
| **GitHubContext** | Object containing authentication, owner, repo, and enterprise details resolved at runtime. |
| **Parameter set** | Named grouping of parameters controlling mutually exclusive function usage patterns. |
