---
description: "How to write XML code in this specific project"
applyTo: "**/*.xml, **/*.ps1xml"
---

## Scope
Covers PowerShell `.Format.ps1xml` and `.Types.ps1xml` for custom views & alias properties.

## Conventions
- 2-space indentation.
- Add new type entries alphabetically by class name.
- Use alias properties for convenience accessors (e.g., `Repository` → `Name`).

## Example Alias
```xml
<AliasProperty>
  <Name>Repository</Name>
  <ReferencedMemberName>Name</ReferencedMemberName>
</AliasProperty>
```

## Validation
- Import module locally to ensure no XML schema errors: `Import-Module ./src/manifest.psd1 -Force`.

## Anti-Patterns
- ❌ Duplicate alias names.
- ❌ Out-of-order `<Type>` entries.
