function Get-GitHubOctocat {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
    #>
    [CmdletBinding()]
    param ()

    $InputObject = @{
        APIEndpoint = '/octocat'
        Method      = 'GET'
    }

    $Response = Invoke-GitHubAPI @InputObject

    $Response
}
