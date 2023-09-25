function Get-GitHubRoot {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
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
