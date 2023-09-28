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

    $body = @{
        context = $Context
        mode    = $Mode
        text    = $Text
    }

    $inputObject = @{
        APIEndpoint = '/markdown'
        Method      = 'POST'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject

}
