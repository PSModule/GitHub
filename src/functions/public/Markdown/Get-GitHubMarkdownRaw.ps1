filter Get-GitHubMarkdownRaw {
    <#
        .NOTES
        [Render a Markdown document in raw mode](https://docs.github.com/rest/reference/meta#github-api-root)
    #>
    [CmdletBinding()]
    param(
        #TODO: Need docs
        [Parameter()]
        [string] $Text,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

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
