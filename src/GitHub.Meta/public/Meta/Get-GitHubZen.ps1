#Requires -Modules GitHub

function Get-GitHubZen {
    <#
    .SYNOPSIS
    Get the Zen of GitHub.

    .DESCRIPTION
    Get a random sentence from the Zen of GitHub.

    .EXAMPLE
    Get-GitHubZen

    Get a random sentence from the Zen of GitHub.

    .NOTES
    https://docs.github.com/rest/meta/meta#get-the-zen-of-github
    #>
    [CmdletBinding()]
    param ()

    $InputObject = @{
        APIEndpoint = '/zen'
        Method      = 'GET'
    }

    $Response = Invoke-GitHubAPI @InputObject

    $Response
}
