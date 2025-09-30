---
applyTo: "**/formats/**/*.Format.ps1xml,**/types/**/*.Types.ps1xml"
description: Repository-specific PowerShell formatting and types patterns for GitHub objects.
---

# GitHub Module Formatting and Types Guidelines

## GitHub Format Files (.Format.ps1xml)
- Create custom table views for GitHub objects optimized for terminal display
- Include most important GitHub properties in default table view
- Use meaningful column headers that match GitHub terminology
- Consider terminal width limitations for GitHub object display

## GitHub Format Patterns
```xml
<TableControl>
    <TableHeaders>
        <TableColumnHeader>
            <Label>Repository</Label>
            <Width>30</Width>
        </TableColumnHeader>
        <TableColumnHeader>
            <Label>Visibility</Label>
            <Width>10</Width>
        </TableColumnHeader>
        <TableColumnHeader>
            <Label>Stars</Label>
            <Width>8</Width>
        </TableColumnHeader>
    </TableHeaders>
</TableControl>
```

## GitHub Types Files (.Types.ps1xml)
- Add property aliases for common GitHub alternate names
- Create calculated properties for derived GitHub data
- Enhance GitHub objects with convenience methods

## GitHub Type Enhancement Examples
- Alias `ID` to `DatabaseID` for GitHub database IDs
- Add class name as alias property (e.g., `Repository` → `Name`)
- Convert GitHub API timestamps to PowerShell DateTime objects
- Size properties in human-readable formats (bytes to MB/GB)
- Add convenience properties like `IsPrivate`, `IsFork`, `HasIssues`

## GitHub Naming Conventions
- Format files: `GitHubObjectName.Format.ps1xml`
- Types files: `GitHubObjectName.Types.ps1xml`
- Match corresponding GitHub class names exactly

## GitHub Display Priorities
- Show most commonly accessed GitHub properties first
- Include contextual information (owner, repository, etc.)
- Use GitHub's terminology and conventions
- Handle both user and organization contexts

## Reference Implementation Files
- See `src/formats/GitHubRepository.Format.ps1xml` for GitHub table formatting
- See `src/types/GitHubRepository.Types.ps1xml` for GitHub property aliases
- Follow GitHub API field naming and conventions
