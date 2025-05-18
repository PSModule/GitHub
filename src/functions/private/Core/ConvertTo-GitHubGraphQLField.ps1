function ConvertTo-GitHubGraphQLField {
    <#
        .SYNOPSIS
        Converts property names to their corresponding GitHub GraphQL field syntax.

        .DESCRIPTION
        Takes a list of property names, optional additional properties, and a property-to-GraphQL mapping table,
        and returns a string of GraphQL fields suitable for use in a query.

        Properties not found in the mapping table are skipped with a warning.

        .EXAMPLE
        $fields = ConvertTo-GitHubGraphQLField -Property @('Name','Owner') -AdditionalProperty 'Url' -PropertyToGraphQLMap $map
        Returns the GraphQL fields for Name, Owner, and Url.

        .OUTPUTS
        string

        .NOTES
        Properties not found in the mapping table are skipped with a warning.
    #>
    [CmdletBinding()]
    param(
        # The main set of property names to include in the GraphQL query.
        [string[]] $PropertyList,

        # A hashtable mapping property names to their GraphQL field syntax.
        [Parameter(Mandatory)]
        [hashtable] $PropertyToGraphQLMap
    )
    $PropertyList = $PropertyList | Select-Object -Unique
    $mappedProperties = $PropertyList | Where-Object { -not [string]::IsNullOrEmpty($_) } | ForEach-Object {
        if ($PropertyToGraphQLMap.ContainsKey($_)) {
            $PropertyToGraphQLMap[$_]
        } else {
            Write-Warning "Property '$_' is not available. Skipping."
        }
    }

    $mappedProperties = $mappedProperties | Select-Object -Unique
    Write-Debug "Mapped properties:"
    $mappedProperties | ForEach-Object { Write-Debug $_ }
    return ($mappedProperties -join "`n")
}
