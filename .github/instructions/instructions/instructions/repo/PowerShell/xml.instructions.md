---
applyTo: "**/*.{xml,ps1xml}"
---

# PowerShell XML Configuration Guidelines

## Format Definition Files
- Use proper PowerShell formatting XML schema
- Define table views with appropriate column widths
- Consider terminal display constraints
- Include meaningful headers and labels

## Type Definition Files  
- Define property aliases for common alternate names
- Add script properties for calculated values
- Maintain consistency with class definitions
- Use proper PowerShell types XML schema

## Common Patterns
```xml
<Configuration>
    <ViewDefinitions>
        <View>
            <Name>GitHubRepository-Table</Name>
            <ViewSelectedBy>
                <TypeName>GitHubRepository</TypeName>
            </ViewSelectedBy>
            <TableControl>
                <TableHeaders>
                    <TableColumnHeader>
                        <Label>Name</Label>
                        <Width>25</Width>
                    </TableColumnHeader>
                </TableHeaders>
                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem>
                                <PropertyName>Name</PropertyName>
                            </TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                </TableRowEntries>
            </TableControl>
        </View>
    </ViewDefinitions>
</Configuration>
```

## File Organization
- One XML file per GitHub object type
- Match file names to corresponding classes
- Place format files in `src/formats/`
- Place type files in `src/types/`