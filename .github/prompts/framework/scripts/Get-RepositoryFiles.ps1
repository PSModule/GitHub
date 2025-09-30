<#
    .SYNOPSIS
    Get a list of all files in a repository and group them by file extension.

    .DESCRIPTION
    This script recursively retrieves all files in the specified repository root directory,
    sorts them by their full path, and then groups them by file extension to provide a count of files per extension.

#>
param(
    # The root directory of the repository to analyze.
    [Parameter(Mandatory)]
    [string] $RepositoryPath
)

$root = [System.IO.Path]::GetFullPath($RepositoryPath)

@"

Analyzing repository at: $root

## Getting files in repository

$((Get-ChildItem -LiteralPath $root -File -Recurse).FullName | Sort-Object | Out-String)

## File counts by extension

$(Get-ChildItem -Path $root -Recurse -File | Group-Object Extension | Select-Object Name, Count | Sort-Object Count -Descending | Out-String)

"@
