---
description: "Code-writing guidelines for JSON in organization projects"
applyTo: "**/*.json"
---

## Style & Formatting
- Indentation: 2 spaces
- Trailing commas: disallowed
- Property order: stable logical grouping (meta → config → rules) to minimize diffs
- Strings: double quotes only
- Booleans: lowercase true/false
- Nulls: omit property instead of `null` unless consumer requires it

## Patterns
- Keep comments out (JSONC not permitted) – document in adjacent README or Markdown comment above snippet.
- Break large arrays ( >10 items ) across lines, one element per line.

## Validation
- Run through schema or tooling (e.g., jscpd config) before commit.

## Example
```json
{
  "$schema": "https://example/schema.json",
  "tool": "jscpd",
  "threshold": 5,
  "languages": ["javascript", "powershell"]
}
```

## Forbidden
- ❌ Duplicate keys
- ❌ Trailing commas
- ❌ Reordering unrelated properties in the same commit
