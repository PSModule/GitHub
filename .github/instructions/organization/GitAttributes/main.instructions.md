---
description: "Code-writing guidelines for .gitattributes in organization projects"
applyTo: "**/.gitattributes"
---

## Goals
Ensure consistent line endings, diff behavior, and linguist overrides.

## Patterns
- Normalize text: `* text=auto eol=lf`
- Enforce PowerShell scripts LF: `*.ps1 text eol=lf`
- Binary detection: mark images `*.png binary`
- Generated files (if any) can be labeled `linguist-generated=true`

## Example
```
* text=auto eol=lf
*.ps1 text eol=lf
*.ps1xml text eol=lf
*.png binary
```

## Forbidden
- ❌ Mixing CRLF & LF rules for same pattern
- ❌ Redundant identical patterns
