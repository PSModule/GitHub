function Get-GitHubMarkdown {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/meta#github-api-root
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Text,

        [Parameter()]
        [ValidateSet('markdown', 'gfm')]
        [string] $Mode,

        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        APIEndpoint = '/markdown'
        Body        = @{
            context = $Context
            mode    = $Mode
            text    = $Text
        }
        Method      = 'POST'
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
