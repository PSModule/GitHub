filter Get-GitHubMarkdown {
    <#
        .SYNOPSIS
        Render a Markdown document

        .DESCRIPTION
        Converts Markdown to HTML

        .EXAMPLE
        Get-GitHubMarkdown -Text "Hello **world**"
        "<p>Hello <strong>world</strong></p>"

        Renders the Markdown text "Hello **world**" to HTML.

        .NOTES
        [Render a Markdown document](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document)
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The Markdown text to render in HTML.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Text,

        # The rendering mode.
        [Parameter()]
        [ValidateSet('markdown', 'gfm')]
        [string] $Mode = 'markdown',

        # The repository context to use when creating references in `gfm` mode. For example, setting `context` to `octo-org/octo-Repository` will
        # change the text `#42` into an HTML link to issue 42 in the `octo-org/octo-Repository` repository.
        [Parameter()]
        [string] $RepoContext,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            context = $RepoContext
            mode    = $Mode
            text    = $Text
        }

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = '/markdown'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
