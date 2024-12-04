filter Get-GitHubRoot {
    <#
        .SYNOPSIS
        GitHub API Root.

        .DESCRIPTION
        Get Hypermedia links to resources accessible in GitHub's REST API.

        .EXAMPLE
        Get-GitHubRoot

        Get the root endpoint for the GitHub API.

        .NOTES
        [GitHub API Root](https://docs.github.com/rest/meta/meta#github-api-root)
    #>
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
