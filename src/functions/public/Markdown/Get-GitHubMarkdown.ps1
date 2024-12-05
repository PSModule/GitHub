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

        #TODO: Need docs
        [Parameter()]
        [string] $RepoContext,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

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
