filter Get-GitHubMarkdown {
    <#
        .NOTES
        [Render a Markdown document](https://docs.github.com/en/rest/markdown/markdown#render-a-markdown-document)
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
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

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
