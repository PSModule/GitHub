function Get-GitHubAPIVersions {
    <#
        .NOTES
        https://docs.github.com/en/rest/meta/meta?apiVersion=2022-11-28#get-all-api-versions
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
