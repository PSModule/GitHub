---
description: "How to write .gitattributes in this specific project"
applyTo: "**/.gitattributes"
---

## Conventions
- Ensure LF normalization for cross-platform contributors.
- Mark PowerShell as text for consistent diffs.

## Current Baseline (append to file if missing)
```
* text=auto eol=lf
*.ps1 text eol=lf
*.ps1xml text eol=lf
```

## Anti-Patterns
- ❌ Adding binary flag to text formats.
