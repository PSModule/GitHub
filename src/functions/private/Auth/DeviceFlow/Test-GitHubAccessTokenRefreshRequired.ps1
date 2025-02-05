﻿function Test-GitHubAccessTokenRefreshRequired {
    <#
        .SYNOPSIS
        Test if the GitHub access token should be refreshed.

        .DESCRIPTION
        Test if the GitHub access token should be refreshed.

        .EXAMPLE
        Test-GitHubAccessTokenRefreshRequired

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
        $tokenExpirationDate = $Context.TokenExpirationDate
        $currentDateTime = Get-Date
        $remainingDuration = [datetime]$tokenExpirationDate - $currentDateTime
        $remainingDuration.TotalHours -lt $script:GitHub.Config.AccessTokenGracePeriodInHours
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
