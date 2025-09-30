---
description: "How to write JSON code in this specific project"
applyTo: "**/*.json"
---

## Scope
Currently only analyzer / duplication configs.

## Conventions
- Keep config minimal; remove unused default keys.
- Document non-obvious thresholds in adjacent README section.

## Example
```json
{
  "threshold": 5,
  "reporters": ["console", "json"]
}
```

## Anti-Patterns
- ❌ Adding comments (breaks strict JSON) → Document separately.
- ❌ Large unrelated reorders in same PR.
