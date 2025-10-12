function Test-GitHubAccessTokenRefreshRequired {
    <#
        .SYNOPSIS
        Test if the GitHub access token should be refreshed.

        .DESCRIPTION
        Test if the GitHub access token should be refreshed.

        .EXAMPLE
        ```pwsh
        Test-GitHubAccessTokenRefreshRequired
        ```

        This will test if the GitHub access token should be refreshed.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            ($Context.TokenExpiresAt - [datetime]::Now).TotalHours -lt $script:GitHub.Config.AccessTokenGracePeriodInHours
        } catch {
            return $true
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
