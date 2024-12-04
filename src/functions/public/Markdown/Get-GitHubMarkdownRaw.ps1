filter Get-GitHubMarkdownRaw {
    <#
        .NOTES
        [Render a Markdown document in raw mode](https://docs.github.com/rest/reference/meta#github-api-root)
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Text,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/markdown/raw'
        ContentType = 'text/plain'
        Body        = $Text
        Method      = 'POST'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
