<#
    .NOTES
    https://docs.github.com/en/rest/meta/meta?apiVersion=2022-11-28#get-all-api-versions
#>
function Get-GitHubApiVersions {
    <#
    .SYNOPSIS
    Get all supported GitHub API versions.

    .DESCRIPTION
    Long description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param ()

    $InputObject = @{
        APIEndpoint = '/versions'
        Method      = 'GET'
    }

    $response = Invoke-GitHubAPI @InputObject

    $response
}
