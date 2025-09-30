---
description: "How to write .gitignore in this specific project"
applyTo: "**/.gitignore"
---

## Conventions
- Only ignore artifacts not meant for source control (build outputs, local env files).
- Group related patterns with blank line separation + comment header.

## Example Block
```
# PowerShell
*.ps1xml

# Local tooling
*.local.ps1
```

## Anti-Patterns
- ❌ Ignoring scripts under `tools/`.
- ❌ Using wildcards that capture future source paths unintentionally.
