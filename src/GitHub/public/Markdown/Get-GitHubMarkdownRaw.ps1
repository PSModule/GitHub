function Get-GitHubMarkdownRaw {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Text,

        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        APIEndpoint = '/markdown/raw'
        ContentType = 'text/plain'
        Data        = $Text
        Method      = 'POST'
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
