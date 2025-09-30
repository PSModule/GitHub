---
description: "How to write Markdown code in this specific project"
applyTo: "**/*.md"
---

## Project Conventions
- Primary audience: users scripting with module + contributors.
- Each example must be executable as-is (assume module imported) or include import line.

## Sections
- README intro sequence: Badge Block → Short Value Prop → Quick Start → Features → Examples → Development.

## Code Blocks
- Prefer `powershell` language tag.
- Multi-step examples: comment headings inside block rather than multiple blocks.

## Example Pattern
```markdown
```powershell
# Get a repository
Get-GitHubRepository -Owner Contoso -Name Portal | Format-List *
```
```

## Anti-Patterns
- ❌ Screenshots for output that can be text.
- ❌ Example without parameter explanation.

## Overrides
- Organization rule on 120 char wrap may be exceeded for one-line commands showing multiple parameters.
