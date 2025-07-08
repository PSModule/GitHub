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

        .LINK
        https://psmodule.io/GitHub/Functions/Meta/Get-GitHubRoot
    #>
    [CmdletBinding()]
    param(
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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/'
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
