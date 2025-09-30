---
description: "Code-writing guidelines for YAML in organization projects"
applyTo: "**/*.yml, **/*.yaml"
---

## Style & Formatting
- Indentation: 2 spaces (never tabs, never 4)
- Max line length: keep under 140 chars where practical
- Keys: lowercase-hyphen-case for workflow/job/step names; camelCase for schema-defined keys
- Quoting: use double quotes only when interpolation, colon, or leading/trailing spaces present; prefer unquoted otherwise
- Booleans: lower-case `true` / `false`
- Null: use explicit `null` only when required; otherwise omit key
- Arrays: prefer block style (`- item`) on separate lines for >1 elements

## File Structure (GitHub Workflows)
Required top order:
1. `name`
2. `on`
3. `env` (optional)
4. `permissions` (least privilege)
5. `jobs`

Within a `job`:
1. `name`
2. `runs-on`
3. `needs` (if any)
4. `permissions` (override)
5. `env`
6. `steps`

Within a `step` order keys: `name`, `id`, `if`, `uses` | `run`, `shell`, `env`, `with`.

## Patterns (Do / Don't)
- ✅ Reuse actions with pinned SHAs (`actions/checkout@<sha>`) not moving tags.
- ✅ Factor repeated env into job `env:`
- ❌ Avoid long multi-line inline scripts; move to PowerShell `.ps1` in repo.
- ❌ Don't use `ubuntu-latest` for matrix; pin explicit version for stability.

## Matrix Strategy
- Always include `fail-fast: false`
- Keep each axis <= 5 values to control build fan-out.

## Anchors & Aliases
- Allowed only for large repetition (3+ identical blocks). Name anchors with UPPER_CASE.

## Error Handling
- Prefer `continue-on-error: false` (default). Use `|| true` only for optional metrics steps.

## Secrets & Security
- Never echo secrets. Mask outputs in PowerShell using `Set-GitHubOutput` patterns.
- Use minimal `permissions:` section; never rely on implicit token scopes.

## Performance
- Use caching (`actions/cache`) keyed by tool version + lock file hash.
- Avoid redundant checkout per job.

## Validation
- Run workflow linter locally before commit when adding new workflows.

## Example (Good Step)
```yaml
- name: Run Unit Tests
  run: pwsh -File tools/utilities/Local-Testing.ps1
  env:
    PSModuleVersion: ${{ env.MODULE_VERSION }}
```

## Forbidden
- ❌ Unpinned 3rd-party actions → ✅ Pin by full commit SHA.
- ❌ Writing secrets to logs → ✅ Use workflow commands for outputs.
