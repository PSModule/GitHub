function Get-GitHubOutput {
    <#
        .SYNOPSIS
        Gets the GitHub output.

        .DESCRIPTION
        Gets the GitHub output from $env:GITHUB_OUTPUT and creates an object with key-value pairs, supporting both single-line and multi-line values

        .EXAMPLE
        Get-GitHubOutput
        MY_VALUE         result                       zen
        --------         ------                       ---
        qwe…             @{"MyOutput":"Hello, World!"} something else

        Gets the GitHub output and returns an object with key-value pairs.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # Returns the output as a hashtable.
        [Parameter()]
        [switch] $AsHashtable
    )

    if (-not $OutputFile) {
        throw 'Environment variable GITHUB_OUTPUT is not set.'
    }

    if (-not (Test-Path -Path $env:GITHUB_OUTPUT)) {
        throw "File not found: $env:GITHUB_OUTPUT"
    }

    Get-Content -Path $env:GITHUB_OUTPUT | ConvertFrom-GitHubOutput -AsHashtable:$AsHashtable
}
