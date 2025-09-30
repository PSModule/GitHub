---
description: "Code-writing guidelines for .gitignore in organization projects"
applyTo: "**/.gitignore"
---

## Principles
Ignore build artifacts, personal tooling files, and temporary caches while tracking source & config.

## Ordering
1. Core language / platform ignores
2. Tooling (editors, analyzers)
3. Local environment / caches
4. Exceptions (negated patterns) immediately after related block

## Patterns
- Use trailing slash for directories (`temp/`)
- Use wildcard for extension groups (`*.log`)
- Add comments (`# Tests coverage artifacts`)

## Example Block
```
# PowerShell
*.ps1xml

# Local
*.local.ps1

# Logs
*.log
```

## Forbidden
- ❌ Ignoring required source (e.g., `src/`)
- ❌ Broad `*` patterns without justification
