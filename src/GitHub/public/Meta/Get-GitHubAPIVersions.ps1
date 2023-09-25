function Get-GitHubApiVersions {
    <#
        .SYNOPSIS
        Get all supported GitHub API versions.

        .DESCRIPTION
        Get all supported GitHub API versions.

        .EXAMPLE
        Get-GitHubApiVersions

        Get all supported GitHub API versions.

        .NOTES
        https://docs.github.com/en/rest/meta/meta?apiVersion=2022-11-28#get-all-api-versions
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param ()

    $inputObject = @{
        ApiEndpoint = '/versions'
        Method      = 'GET'
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
