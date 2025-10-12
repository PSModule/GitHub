filter Get-GitHubZen {
    <#
        .SYNOPSIS
        Get the Zen of GitHub.

        .DESCRIPTION
        Get a random sentence from the Zen of GitHub.

        .EXAMPLE
        ```powershell
        Get-GitHubZen
        ```

        Get a random sentence from the Zen of GitHub.

        .NOTES
        [Get the Zen of GitHub](https://docs.github.com/rest/meta/meta#get-the-zen-of-github)

        .LINK
        https://psmodule.io/GitHub/Functions/Meta/Get-GitHubZen
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
            APIEndpoint = '/zen'
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
