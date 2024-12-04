filter Get-GitHubMarkdown {
    <#
        .NOTES
        [Render a Markdown document](https://docs.github.com/en/rest/markdown/markdown#render-a-markdown-document)
    #>
    [CmdletBinding()]
    param(
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
        [string] $RepoContext,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $body = @{
        context = $RepoContext
        mode    = $Mode
        text    = $Text
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/markdown'
        Method      = 'POST'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
