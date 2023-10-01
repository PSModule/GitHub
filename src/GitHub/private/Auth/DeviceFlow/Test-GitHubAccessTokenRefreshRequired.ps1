function Test-GitHubAccessTokenRefreshRequired {
    <#
        .SYNOPSIS
        Test if the GitHub access token should be refreshed.

        .DESCRIPTION
        Test if the GitHub access token should be refreshed.

        .EXAMPLE
        Test-GitHubAccessTokenRefreshRequired

        This will test if the GitHub access token should be refreshed.
    #>
    [CmdletBinding()]
    param()

    $tokenExpirationDate = Get-GitHubConfig -Name 'AccessTokenExpirationDate' -ErrorAction SilentlyContinue
    if (-not $tokenExpirationDate) {
        return $false
    }
    $currentDateTime = Get-Date

    # Calulate the remaining time in hours
    $remainindDuration = [datetime]$tokenExpirationDate - $currentDateTime

    # If the remaining time is less that $script:Auth.AccessTokenGracePeriodInHours then the token should be refreshed
    $remainindDuration.TotalHours -lt $script:Auth.AccessTokenGracePeriodInHours
}
