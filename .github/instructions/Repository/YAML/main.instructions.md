---
description: "How to write YAML code in this specific project"
applyTo: "**/*.yml, **/*.yaml"
---

## Project Conventions
- Workflows orchestrate module tests, lint, release. Logic lives in PowerShell scripts under `tools/` or `tests/`.
- Reusable workflows not yet adopted; prefer composite action only after >2 reuse cases.

## Naming
- File names: `Pascal-UseCase.yml` (e.g., `Process-PSModule.yml`)
- Workflow `name:` mirrors filename (spaces allowed).

## Permissions
- Explicit `permissions:` block in every workflow with least privileges (often `contents: read`).

## Caching
- Cache PSModule path & PowerShell module downloads keyed by module version + OS.

## Example Snippet
```yaml
jobs:
  test:
    runs-on: ubuntu-22.04
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<sha>
      - name: Install PowerShell
        uses: PowerShell/PowerShell-For-GitHub-Actions@<sha>
      - name: Run Tests
        run: pwsh -File tools/utilities/Local-Testing.ps1
```

## Anti-Patterns
- ❌ Embedding >30 lines script in `run:` → ✅ Move to tracked `.ps1` file.
- ❌ Using default token permissions → ✅ Declare minimal `permissions:`.
- ❌ Unpinned action versions → ✅ Pin to commit SHA.

## Overrides (vs Org Rules)
- Allow longer step names (up to 80 chars) for clarity.
