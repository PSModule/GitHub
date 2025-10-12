filter Get-GitHubMarkdown {
    <#
        .SYNOPSIS
        Render a Markdown document

        .DESCRIPTION
        Converts Markdown to HTML

        .EXAMPLE
        ```powershell
        Get-GitHubMarkdown -Text "Hello **world**"
        "<p>Hello <strong>world</strong></p>"
        ```

        Renders the Markdown text "Hello **world**" to HTML.

        .NOTES
        [Render a Markdown document](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document)

        .LINK
        https://psmodule.io/GitHub/Functions/Markdown/Get-GitHubMarkdown
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

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $body = @{
            context = $RepoContext
            mode    = $Mode
            text    = $Text
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = '/markdown'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
