filter Get-GitHubMarkdownRaw {
    <#
        .SYNOPSIS
        Render a Markdown document in raw mode

        .DESCRIPTION
        You must send Markdown as plain text (using a `Content-Type` header of `text/plain` or `text/x-markdown`) to this endpoint, rather than using
        JSON format. In raw mode, [GitHub Flavored Markdown](https://github.github.com/gfm/) is not supported and Markdown will be rendered in plain
        format like a README.md file. Markdown content must be 400 KB or less.

        .EXAMPLE
        Get-GitHubMarkdownRaw -Text 'Hello, world!'
        "<p>Hello <strong>world</strong></p>"

        Render the Markdown text 'Hello, world!' in raw mode.

        .NOTES
        [Render a Markdown document in raw mode](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document-in-raw-mode)
    #>
    [CmdletBinding()]
    param(
        # The Markdown text to render in HTML.
        [Parameter()]
        [string] $Text,

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
            text = $Text
        }

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = '/markdown/raw'
            ContentType = 'text/plain'
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
