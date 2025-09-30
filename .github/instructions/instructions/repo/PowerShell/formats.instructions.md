---
applyTo: '**/src/formats/**/*.Format.ps1xml'
description: PowerShell formatting files for custom display of objects.
---

# PowerShell Format Guidelines

## File Structure
- XML format files define how objects appear in console output
- Name format: `ObjectType.Format.ps1xml` (e.g., `GitHubRepository.Format.ps1xml`)
- Include both table and list views where appropriate

## Table Views
- Use descriptive column headers with `<Label>` elements
- Implement conditional formatting with `<ScriptBlock>` elements
- Support virtual terminal colors with `$Host.UI.SupportsVirtualTerminal` checks
- Disable colors in GitHub Actions: `($env:GITHUB_ACTIONS -ne 'true')`

## Color Patterns
```xml
<ScriptBlock>
    if ($Host.UI.SupportsVirtualTerminal -and
    ($env:GITHUB_ACTIONS -ne 'true')) {
        "`e[32m$($_.Property)`e[0m"
    } else {
        $_.Property
    }
</ScriptBlock>
```

## Property Selection
- Show most relevant properties in table view
- Limit columns to fit standard terminal widths
- Use calculated properties for complex display logic
- Include status indicators where meaningful

## View Selection
- Define `<ViewSelectedBy><TypeName>` to match class names
- Create multiple views for different use cases if needed
- Use consistent naming: `ObjectTypeTable`, `ObjectTypeList`
- Ensure views work across different PowerShell hosts

## Performance Considerations
- Keep script blocks simple and fast
- Avoid expensive operations in formatting code
- Cache repeated calculations where possible
- Test formatting with large object collections
