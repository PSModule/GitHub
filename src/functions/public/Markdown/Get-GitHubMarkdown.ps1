filter Get-GitHubMarkdown {
    <#
        .SYNOPSIS
        Render a Markdown document

        .DESCRIPTION
        Converts markdown to html

        .EXAMPLE
        Get-GitHubMarkdown -Text "Hello **world**"
        "<p>Hello <strong>world</strong></p>"

        Renders the markdown text "Hello **world**" to HTML.

        .NOTES
        [Render a Markdown document](https://docs.github.com/en/rest/markdown/markdown#render-a-markdown-document)
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
        [switch] $Text,

        # The rendering mode.
        [Parameter()]
        [ValidateSet('markdown', 'gfm')]
        [string] $Mode,

        # The repository context to use when creating references in `gfm` mode. For example, setting `context` to `octo-org/octo-repo` will change the
        # text `#42` into an HTML link to issue 42 in the `octo-org/octo-repo` repository.
        [Parameter()]
        [string] $RepoContext,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
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
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
