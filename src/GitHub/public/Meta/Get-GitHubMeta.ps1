function Get-GitHubMeta {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
    #>
    [CmdletBinding()]
    param ()

    $InputObject = @{
        APIEndpoint = '/meta'
        Method      = 'GET'
    }

    $response = Invoke-GitHubAPI @InputObject -AccessToken $null

    $response
}
