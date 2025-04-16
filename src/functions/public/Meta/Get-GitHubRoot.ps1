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
        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        if (-not $Anonymous) {
            $Context = Resolve-GitHubContext -Context $Context
            Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        }
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/'
            Anonymous   = $Anonymous
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
