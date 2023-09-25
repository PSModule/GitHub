#Requires -Modules GitHub

function Get-GitHubRoot {
    <#
        .SYNOPSIS
        GitHub API Root.

        .DESCRIPTION
        Get Hypermedia links to resources accessible in GitHub's REST API.

        .EXAMPLE
        Get-GitHubRoot

        Get the root endpoint for the GitHub API.

        .NOTES
        https://docs.github.com/rest/meta/meta#github-api-root
    #>
    [CmdletBinding()]
    param ()

    $InputObject = @{
        APIEndpoint = '/'
        Method      = 'GET'
    }

    $response = Invoke-GitHubAPI @InputObject

    $response
}
