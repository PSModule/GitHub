---
description: "Code-writing guidelines for XML in organization projects"
applyTo: "**/*.xml, **/*.ps1xml"
---

## Scope
Covers PowerShell metadata: `.Format.ps1xml` and `.Types.ps1xml` files.

## Formatting
- Indentation: 2 spaces
- XML Declaration: omit unless required by consumer
- Attributes: use double quotes, one space before attribute list
- Close empty elements explicitly (`<Members></Members>`) for clarity

## Ordering
- Types files: `<Type>` entries alphabetically by `<Name>`
- Format files: Group `<View>` entries by related object type; inside `<TableControl>` maintain header → rows sequence
- Alias properties: define before ScriptProperty for the same type

## Patterns
Alias property example:
```xml
<Type>
  <Name>GitHubRepository</Name>
  <Members>
    <AliasProperty>
      <Name>Repository</Name>
      <ReferencedMemberName>Name</ReferencedMemberName>
    </AliasProperty>
  </Members>
</Type>
```

Format table example (abbreviated):
```xml
<View>
  <Name>GitHubRepository</Name>
  <ViewSelectedBy>
    <TypeName>GitHubRepository</TypeName>
  </ViewSelectedBy>
  <TableControl>
    <TableHeaders>
      <TableColumnHeader><Label>Name</Label></TableColumnHeader>
      <TableColumnHeader><Label>Owner</Label></TableColumnHeader>
    </TableHeaders>
    <TableRowEntries>
      <TableRowEntry>
        <TableColumnItems>
          <TableColumnItem><PropertyName>Name</PropertyName></TableColumnItem>
          <TableColumnItem><PropertyName>Owner</PropertyName></TableColumnItem>
        </TableColumnItems>
      </TableRowEntry>
    </TableRowEntries>
  </TableControl>
</View>
```

## Validation
- Ensure all referenced properties exist on classes
- Run module import to validate formatting (PowerShell will error on malformed metadata)

## Forbidden
- ❌ Tabs for indentation
- ❌ Unsorted `<Type>` definitions
- ❌ Duplicate `<AliasProperty>` entries
