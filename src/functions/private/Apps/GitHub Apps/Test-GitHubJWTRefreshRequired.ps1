function Test-GitHubJWTRefreshRequired {
    <#
        .SYNOPSIS
        Test if the GitHub JWT should be refreshed.

        .DESCRIPTION
        Test if the GitHub JWT should be refreshed. JWTs are refreshed when they have 150 seconds or less remaining before expiration.

        .EXAMPLE
        Test-GitHubJWTRefreshRequired -Context $Context

        This will test if the GitHub JWT should be refreshed for the specified context.

        .NOTES
        JWTs are short-lived tokens (typically 10 minutes) and need to be refreshed more frequently than user access tokens.
        The refresh threshold is set to 150 seconds (2.5 minutes) to ensure the JWT doesn't expire during API operations.
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
            if ($null -eq $Context.TokenExpiresAt) {
                Write-Debug 'TokenExpiresAt is null, refresh required'
                return $true
            }

            $tokenExpiresAt = $Context.TokenExpiresAt
            $currentDateTime = [datetime]::Now
            $remainingDuration = [datetime]$tokenExpiresAt - $currentDateTime

            Write-Debug "JWT expires at: $tokenExpiresAt"
            Write-Debug "Current time: $currentDateTime"
            Write-Debug "Remaining duration: $($remainingDuration.TotalSeconds) seconds"

            # Refresh on half-life
            $refreshRequired = $remainingDuration.TotalSeconds -le ($script:GitHub.Config.JwtRefreshThreshold / 2)
            Write-Debug "Refresh required: $refreshRequired"

            return $refreshRequired
        } catch {
            Write-Debug "Error checking JWT expiration: $_"
            return $true
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
