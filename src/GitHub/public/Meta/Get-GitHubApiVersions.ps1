function Get-GitHubApiVersions {
    <#
        .SYNOPSIS
        Get all API versions.

        .DESCRIPTION
        Get all supported GitHub API versions.

        .EXAMPLE
        Get-GitHubApiVersions

        Get all supported GitHub API versions.

        .NOTES
        https://docs.github.com/rest/meta/meta#get-all-api-versions
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param ()

    $inputObject = @{
        ApiEndpoint = '/versions'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject

}
