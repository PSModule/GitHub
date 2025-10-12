filter Get-GitHubMarkdownRaw {
    <#
        .SYNOPSIS
        Render a Markdown document in raw mode

        .DESCRIPTION
        You must send Markdown as plain text (using a `Content-Type` header of `text/plain` or `text/x-markdown`) to this endpoint, rather than using
        JSON format. In raw mode, [GitHub Flavored Markdown](https://github.github.com/gfm/) is not supported and Markdown will be rendered in plain
        format like a README.md file. Markdown content must be 400 KB or less.

        .EXAMPLE
        ```pwsh
        Get-GitHubMarkdownRaw -Text 'Hello, world!'
        "<p>Hello <strong>world</strong></p>"
        ```

        Render the Markdown text 'Hello, world!' in raw mode.

        .NOTES
        [Render a Markdown document in raw mode](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document-in-raw-mode)

        .LINK
        https://psmodule.io/GitHub/Functions/Markdown/Get-GitHubMarkdownRaw
    #>
    [CmdletBinding()]
    param(
        # The Markdown text to render in HTML.
        [Parameter()]
        [string] $Text,

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
            text = $Text
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = '/markdown/raw'
            ContentType = 'text/plain'
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
