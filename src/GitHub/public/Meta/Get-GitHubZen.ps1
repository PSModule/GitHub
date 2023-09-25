function Get-GitHubZen {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
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
