---
description: "Code-writing guidelines for Markdown in organization projects"
applyTo: "**/*.md"
---

## Style & Formatting
- Headings: Start at `#` for document title, never skip levels.
- Line length: wrap prose ~120 chars (soft), code blocks unwrapped.
- Lists: use `-` for unordered, `1.` for ordered (auto-increment).
- Code fences: always specify language (e.g., ```powershell, ```yaml).
- Blank lines: one blank line before/after headings, lists, and code fences.

## Links
- Relative links for repo targets (`./path/file.md`).
- Use reference-style only when reused >= 3 times.

## Tables
- Align with `|` separators, no trailing spaces inside cells.

## Inline Code & Escapes
- Use backticks for parameter names / commands.

## Examples Section Pattern
```markdown
### Example
```powershell
Get-GitHubRepository -Owner org -Name repo
```
Short explanation.
```

## Bad vs Good
```markdown
<!-- BAD -->
```powershell
Get-GitHubRepository
```
No context.

<!-- GOOD -->
```powershell
Get-GitHubRepository -Owner Contoso -Name Portal
```
Returns repository object with metadata.
```

## Forbidden
- ❌ HTML for basic formatting → ✅ Pure Markdown.
- ❌ Mixed heading styles (`Setext` + `ATX`) → ✅ Use ATX only.
