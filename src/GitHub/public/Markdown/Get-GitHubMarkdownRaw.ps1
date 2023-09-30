function Get-GitHubMarkdownRaw {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Text
    )

    $inputObject = @{
        APIEndpoint = '/markdown/raw'
        ContentType = 'text/plain'
        Body        = $Text
        Method      = 'POST'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
